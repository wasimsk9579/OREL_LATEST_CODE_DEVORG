import { LightningElement,api,track,wire } from 'lwc';
import getReturnorder from '@salesforce/apex/orlReturnOrderController.getReturnorder';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from 'lightning/navigation';
const DEFAULT_PAGE_SIZE = 5; 
export default class OrelReturnOrderTable extends LightningElement {

    @api recordId; // An API property to accept record Ids from the parent component.
    userId =Id; // A property to store the current user's Id retrieved from @salesforce/user/Id.
    allData = []; // An array to store the retrieved data from the Apex method.
    initialData = []; // A copy of allData to store the initial data for filtering purposes.
    @track currentPage = 1; 
    totalPages = 1;
    @track pageSize = DEFAULT_PAGE_SIZE;
    @track isLastPage = false; // A boolean variable to determine if the current page is the last page.
    @track variable = false; // A boole
    isvariable = false;
    clickedreturnId;
    @track vfPageUrl = ''; // Initialize with empty string
    @track iframeKey = 0; // To force the iframe to refresh
    vfvariable=false;
    advancereturn;

    columns = [
        {label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
        {label: 'Customer', fieldName: 'customerName', type: 'text', sortable: true },
        //{label: 'Return Status', fieldName: 'returnstatus', type: 'text', sortable: true },
        {
            label: 'Return Status',
            fieldName: 'returnstatus',
            type: 'text',
            sortable: true,
            editable: true,
            wrapText: true},
        //     typeAttributes: {
        //         placeholder: 'Choose field',
        //         options: [
        //             { label: 'Draft', value: 'Draft' },
        //             { label: 'Approved', value: 'Approved' },
        //             { label: 'Received at distributor W/H', value: 'Received at distributor W/H' },
        //             { label: 'Sent to Orel W/H', value: 'Sent to Orel W/H' },
        //             { label: 'Received at Orel W/H', value: 'Received at Orel W/H' },
        //             { label: 'QC InProgress', value: 'QC InProgress' },
        //             { label: 'Completed', value: 'Completed' }
        //             // Add more options as needed
        //         ]
        //     }
        // },
        {label: 'Order date', fieldName: 'Orderdate', type: 'text', sortable: true },
        {label: 'Initiate Date', fieldName: 'InitiateDate', type: 'text', sortable: true },
        {label: 'Delivery Date', fieldName: 'DeliveryDate', type: 'text', sortable: true },
        {label: 'Delivery Recipient', fieldName: 'deliveryrecipient', type: 'text'},
        
        
        {
            label: 'Action',
            type: 'button',
            typeAttributes: {
                label: 'Click here',
                title: 'Click here',
                variant: 'brand',
                name: 'view_details'
            }
        }, 
        {
            label: 'Action',
            type: 'button',
            typeAttributes: {
                label: 'Print',
                variant: 'brand',
                name: 'open_vf_page',
                title: 'Click to Open VF Page'
            }
        }
    ];

   
 
    connectedCallback() {
        this.userId = Id;
        this.callApexMethod();
        console.log('userid',this.userId )

    }

    callApexMethod() {
        getReturnorder({ userId: this.userId })
            .then(result => {  
                this.allData = result.map((item,ind)=>({
                    
                    ...item,
                    Name:item.Name,
                    customerName:item.cgcloud__Order_Account__r.Name,
                    deliveryrecipient:item.cgcloud__Delivery_Recipient__r?.Name || '  ',
                    Orderdate:item.cgcloud__Order_Date__c,
                    InitiateDate:item.cgcloud__Initiation_Date__c,
                    DeliveryDate:item.cgcloud__Delivery_Date__c,
                    returnstatus:item.Orl_Return_Status__c,
                   
    

                }));
                this.allData.forEach(record => {
                    // Make sure the picklist values match exactly with the options
                    if (record.returnstatus) {
                        const lowerCaseStatus = record.returnstatus.toLowerCase();
                        if (!this.options.find(option => option.value.toLowerCase() === lowerCaseStatus)) {
                            this.options.push({ label: record.returnstatus, value: record.returnstatus });
                        }
                    }
                });
                console.log('resultt' +JSON.stringify(result));
                this.initialData = [...this.allData];
                this.updateTotalPages();
                this.paginateData();
            })
            .catch(error => {
                console.error('Error fetching data:', error);   
                console.log('erorrrrrrrrrrrrr');         
            });
    }

    renderedCallback() {
        // Check if picklist values need to be rendered
        if (this.allData && this.allData.length > 0) {
            // Iterate through the rows and render picklist values
            this.allData.forEach((row) => {
                const picklistValue = row.returnstatus;
                if (picklistValue) {
                    // Replace the picklist value in the row with a combobox component
                    const comboboxComponent = this.createComboboxComponent(picklistValue);
                    row.returnstatus = comboboxComponent;
                }
            });
        }
    }
    
    createComboboxComponent(selectedValue) {
        // Create a lightning-combobox component with picklist values
        return (
            // Use appropriate combobox attributes
            // For example:
            `<lightning-combobox
                name="returnStatus"
                label="Return Status"
                value=${selectedValue}
                options=${JSON.stringify(this.picklistOptions)}
                onchange={handleComboboxChange}>
            </lightning-combobox>`
        );
    }

    handleComboboxChange(event) {
        // Handle combobox change event, if needed
        console.log('Combobox value changed:', event.detail.value);
    }
    

  //  onHandleSort: A method to handle sorting of the data based on column headers.

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allData];
        cloneData.sort((a, b) => {
            return this.sortBy(a, b, sortedBy, sortDirection);
        });
        this.allData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
// sortBy: A helper method used in sorting the data.
        sortBy(a, b, fieldName, sortDirection) {
            const valueA = a[fieldName];
            const valueB = b[fieldName];
            let comparison = 0;   

            if (valueA === valueB) {
                comparison = a.index > b.index ? 1 : a.index < b.index ? -1 : 0;
            } else if (typeof valueA === 'string' && typeof valueB === 'string') {
                comparison = valueA.toLowerCase().localeCompare(valueB.toLowerCase());
            } else if (!isNaN(valueA) && !isNaN(valueB)) {
                comparison = parseFloat(valueA) - parseFloat(valueB);
            }
            return sortDirection === 'asc' ? comparison : -comparison;
        }

// handleSearch: A method to handle searching/filtering of the data based on user input.

handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    this.currentPage = 1;
    if (searchTerm) {
        this.allData = this.initialData.filter(item =>
            Object.values(item).some(value =>
                value && value.toString().toLowerCase().includes(searchTerm)
            )
        );
        const searchResultSize = this.allData.length;
        this.pageSize = searchResultSize <= DEFAULT_PAGE_SIZE ? searchResultSize : DEFAULT_PAGE_SIZE;
        this.allData = this.allData.slice(0, this.pageSize);

    } else {
         this.variable = false;       
         this.paginateData();
    }    
}

// updateTotalPages: A method to calculate the total number of pages based on the data size and page size.

    updateTotalPages() {
              this.totalPages = Math.ceil(this.initialData.length / DEFAULT_PAGE_SIZE);
    }
// paginateData: A method to slice and display the data based on the current page and page size
    paginateData() {
        const startIndex = (this.currentPage - 1) * DEFAULT_PAGE_SIZE;
        const endIndex = startIndex + DEFAULT_PAGE_SIZE;
        this.allData = this.initialData.slice(startIndex, endIndex).map((item, index) => ({
            ...item,
            index: startIndex + index + 1,
        }));
    }
// handlePrevious and handleNext: Methods to navigate to the previous and next pages.    
    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.paginateData();
        }
    }    
    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.paginateData();
        }
    }
// isFirstPage and isLastPage: Computed properties to check if the current page is the first or last page.    
    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
  
    recId;
    handleRowAction(event) {
        console.log('row action -- ', JSON.stringify(event.detail.row.Id));
        const action = event.detail.action;
        this.recId = event.detail.row.Id;
    
        // Check which action was performed
        switch (action.name) {
            case 'view_details':
                // Set the clickedreturnId to perform necessary operations in your component
                this.clickedreturnId = this.recId;
                // Show the template where variable is true
                this.variable = true;
                this.isvariable = false; // Ensure isvariable template is hidden
                break;
            case 'open_vf_page':
                // Set the clickvfId to perform necessary operations in your component
                //this.clickvfId = recId;
                // Show the template where isvariable is true
                this.isvariable = true;
                this.variable = false; // Ensure variable template is hidden
                break;
            default:
                break;
        }
    }
    get iframeSrc() {

        console.log('hiiii',this.recId )
        return '/apex/returnordervfpage?Id=' +this.recId;
   
    }
    
    handleBackToReturnList()
    {
        this.variable = false;
    }
    handleCancel()
    {
        this.isvariable = false; 
    }

}