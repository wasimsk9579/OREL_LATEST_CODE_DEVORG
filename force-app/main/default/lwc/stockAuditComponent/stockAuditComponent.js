import { LightningElement, track, wire } from 'lwc';
import getInventoryList from '@salesforce/apex/InventoryController.getInventoryList';
import createStockAudit from '@salesforce/apex/InventoryController.createStockAudit';
import { refreshApex } from '@salesforce/apex';

const DEFAULT_PAGE_SIZE = 20;

export default class StockAuditComponent extends LightningElement {
    @track selectedAccountId = '';
    @track selectedTemplateType = '';
    @track accountOptions = [];
    @track templateTypeOptions = [];
    @track inventoryList = [];
    invlist = [];
    @track filteredInventory = [];
    finalDataList = [];
    @track currentPageData = [];
    pageSize = DEFAULT_PAGE_SIZE;
    @track totalPages;
    @track pageNumber = 1;
    totalRecords = 0;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    rowOffset = 0;
    selection = [];

    pageSizeOptions = [
        { label: '5', value:5 },
        { label: '10', value:10 },
        { label: '20', value:20 },
        { label: '30', value: 30 },
        { label: '50', value: 50 },
        { label: '75', value: 75 },
        { label: '100', value: 100 }
    ];

    columns = [
        { label: 'Inventory Name', fieldName: 'Name', type: 'text' },
        { label: 'Product Name', fieldName: 'product_name', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Quantity', fieldName: 'cgcloud__Balance__c', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Template Type', fieldName: 'Inventory_Control_Template_Type__c', type: 'text' },
        { label: 'Actual Amount', fieldName: 'Actual_Amount__c', type: 'number', editable: true, sortable: true, cellAttributes: { alignment: 'left' } }
        // Add more columns as needed
    ];

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
   

    onHandleSort(event) {
        
        const { fieldName: sortedBy, sortDirection } = event.detail;
        
        const cloneData = [...this.currentPageData];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.currentPageData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    @wire(getInventoryList)
    wiredInventory({ error, data }) {
        if (data) {

            this.invlist = data.map(item => ({
            ...item,
            Actual_Amount__c: item.Actual_Amount__c || 0,
            isSelected: false, // Add the isSelected property
        }));

            //this.invlist = data;
            this.totalRecords = data.length; // update total records count                 
            this.handleActualQuantity();
            this.paginationHelper();
            this.buildAccountOptions();
            this.buildTemplateTypeOptions();
            this.filterInventoryList();
        } else if (error) {
            console.error('Error retrieving inventory data:', error);
        }
    }

    buildAccountOptions() {
        this.accountOptions = [
            { label: 'All', value: '' },
            ...Array.from(new Set(this.invlist.map(item => item.cgcloud__Account__r.Name)))
                .map(accountName => ({ label: accountName, value: this.invlist.find(item => item.cgcloud__Account__r.Name === accountName).cgcloud__Account__c })),
        ];
    }

    buildTemplateTypeOptions() {
        this.templateTypeOptions = [
            { label: 'All', value: '' },
            ...Array.from(new Set(this.invlist.map(item => item.Inventory_Control_Template_Type__c)))
                .filter(templateType => templateType) // Filter out empty template types
                .map(templateType => ({ label: templateType, value: templateType })),
        ];
    }

    filterInventoryList() {
        this.filteredInventory = this.invlist.map(item => ({
            ...item,
            Actual_Amount__c: item.Actual_Amount__c || 0,
            isSelected: item.isSelected || false,
        })).filter(item =>
            (!this.selectedAccountId || item.cgcloud__Account__c === this.selectedAccountId) &&
            (!this.selectedTemplateType || item.Inventory_Control_Template_Type__c === this.selectedTemplateType)
        );

        this.sortInventory();

        // Update the selection array with the updated records
        // this.selection = this.invlist
        //     .filter(item => item.isSelected)
        //     .map(item => item.Name);

        //     console.log('isselected >>',this.selection);

        console.log('the filtered inventory is>>',this.filteredInventory[0]);
        // Calculate total pages
        this.totalPages = Math.ceil(this.filteredInventory.length / this.pageSize);

        // Refresh the current page data based on the new filtered inventory
        this.refreshCurrentPageData();
    }



    sortInventory() {
        if (this.sortedBy) {
            // Sort the filtered inventory based on the current sorting parameters
            const reverse = this.sortDirection === 'asc' ? 1 : -1;
            this.filteredInventory.sort(this.sortBy(this.sortedBy, reverse));
        }
    }

    handlesearch(event) {
       console.log('thanks for searching');
       console.log('this.selectedAccountId11',this.selectedAccountId);
       console.log('this.selectedTemplateType',this.selectedTemplateType);
        this.pageNumber = 1; // Reset page number to 1 when changing filters
        this.filterInventoryList();
    }

    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        console.log('this.selectedAccountId11',this.selectedAccountId);
    // this.pageNumber = 1; // Reset page number to 1 when changing filters
    /// this.filterInventoryList();
    }

    handleTemplateTypeChange(event) {
        this.selectedTemplateType = event.detail.value;
        //this.pageNumber = 1; // Reset page number to 1 when changing filters
        //this.filterInventoryList();
    }

    handleRowSelection(evt) {
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();

        this.currentPageData.map((event) => {
            loadedItemsSet.add(event.Name);
        });

        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Name);
            });

            // Update the isSelected property for each item
            this.filteredInventory.forEach(item => {
                item.isSelected = updatedItemsSet.has(item.Name);
            });
        }

        loadedItemsSet.forEach((Name) => {
            const item = this.filteredInventory.find(item => item.Name === Name);
            if (item) {
                this.selection = item.isSelected ? [...this.selection, Name] : this.selection.filter(sel => sel !== Name);
            }
        });

        console.log('Selection::');
        console.log(this.selection);
    }



    handlePageSizeChange(event) {
        this.pageSize = event.detail.value;
        this.pageNumber = 1; // Reset page number to 1 when changing page size
        this.filterInventoryList();
    }

    
    handleRecordsPerPage(event) {
               
        this.pageNumber = 1; // Reset page number to 1 when changing page size
        this.pageSize = parseInt(event.detail.value, 10);
        this.filterInventoryList();
        
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.refreshCurrentPageData();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.refreshCurrentPageData();
    }

    firstPage() {
        this.pageNumber = 1;
        this.refreshCurrentPageData();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.refreshCurrentPageData();
    }

    refreshCurrentPageData() {
        
        const startIndex = (this.pageNumber - 1) * this.pageSize;
        const endIndex = this.pageNumber * this.pageSize;
        this.rowOffset = startIndex;

        // Apply any filtering or sorting based on the updated invlist
        const filteredAndSortedInventory = this.filteredInventory
        .map((item, index) => ({
            ...item,
            index: startIndex + index + 1 + this.calculateCumulativeIndex(startIndex + index + 1),
            product_name: item.cgcloud__Product__r.Name
        }));

        // Update the current page data based on pagination
        this.currentPageData = filteredAndSortedInventory.slice(startIndex, endIndex);

        // Update the selection array based on the isSelected property
        this.selection = this.invlist
            .filter(item => item.isSelected)
            .map(item => item.Name);
            console.log('the sected items are>>',this.selection);   
    }
    
    calculateCumulativeIndex(currentIndex) {
        // Calculate the cumulative index based on the total number of records and the current index
        return (this.pageNumber - 1) * this.pageSize + currentIndex;
    }
    

    handleCellChange(event) {
        const { draftValues } = event.detail;
        draftValues.forEach(change => {
            const { Actual_Amount__c, Name } = change;
            this.invlist = this.invlist.map(item => {
                if (item.Name === Name) {
                    const newItem = { ...item, Actual_Amount__c: parseInt(Actual_Amount__c, 10) || 0, isSelected: true };
                    return newItem;
                }
                return item;
            });
        });

        // Update the selection array with the updated records
        this.selection = this.invlist
            .filter(item => item.isSelected)
            .map(item => item.Name);

            console.log('isselected >>',this.selection);

        this.filterInventoryList();
        this.refreshCurrentPageData();
    }


    handleActualQuantity(){
        const updatedInventory = this.invlist.map(item => {                
            
            const newItem = { ...item, Actual_Amount__c: 0 };
            const newAmount = 0;
            newItem.Actual_Amount__c = 0;
            
            return newItem;           
            
        });

        this.invlist = updatedInventory;
        console.log('amount updated',this.invlist);
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        //this.refreshCurrentPageData();
    }

    // handlePagination(event) {
    //     this.pageNumber = event.detail.page;
    //     this.refreshCurrentPageData();
    // }

    handleSave(event){
         // Update filteredInvList based on the filtered and sorted invlist
        this.finalDataList = this.invlist
        .filter(item => item.isSelected) // Only include items where isSelected is true
        .map(item => ({
            Id: item.Id,
            cgcloud_Balance: item.cgcloud__Balance__c,
            Name: item.cgcloud__Product__r.Name,
            Actual_Amount: item.Actual_Amount__c,
            Inventory_Type: item.Inventory_Control_Template_Type__c,
        }));

        

        // Call the Apex method
        createStockAudit({ 
            datalist: this.finalDataList,
            selectedAccountName: this.selectedAccountId
            })
            .then(result => {
                refreshApex(this. invlist);

                this.invlist = this. invlist.map(item => ({
                    ...item,
                    Actual_Amount__c: item.Actual_Amount__c || 0,
                    isSelected: false, // Add the isSelected property
                }));
                // Handle the result as needed

                this.selection = [];
                console.log('Result from Apex method:891', result);
            })
            .catch(error => {
                refreshApex(this. invlist);
                // Handle any errors
                console.error('Error calling Apex method:', error);
            });

            console.log('the final data8',this.finalDataList );
    }
}