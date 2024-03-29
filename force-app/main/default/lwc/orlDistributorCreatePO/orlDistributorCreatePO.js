import { LightningElement, track, wire } from 'lwc';
import getProductsForDistributor from '@salesforce/apex/OrlDistributorCreatePOController.getProductsForDistributor';
import createPurchaseOrder from '@salesforce/apex/OrlDistributorCreatePOController.createOppAndOppLineItems';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const DEFAULT_PAGE_SIZE = 10;
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Product Code', fieldName: 'ProductCode', type: 'text' },
    { label: 'Category', fieldName: 'categoryName', type: 'text'},
    { label: 'Unit Price', fieldName: 'productPrice', type: 'currency',cellAttributes: { alignment: 'left' } }
];
export default class OrlDistributorCreatePO extends LightningElement {
    productsData;
    errorMessage = '';
    globalAskedQuantity;
    initialData;
    columns = columns;
    page1 = true;
    selectedProducts = [];
    showSpinner = false;
    preSelectedRows =[];
    @track currentPage = 1; 
    totalPages = 1;
    @track pageSize = DEFAULT_PAGE_SIZE;
    @track isLastPage = false;

    connectedCallback(){
        console.log('userID -- ', userId);
        getProductsForDistributor({currentUserId : userId})
        .then(result => {
            console.log('result ==> ', result);
            let backendData = result;
            for(let i=0; i < backendData.length; i++){  
                backendData[i].categoryName = backendData[i].ProductCategoryProducts[0].ProductCategory.Name;
                if(backendData[i].PricebookEntries){
                    backendData[i].productPrice = backendData[i].PricebookEntries[0].UnitPrice;
                }else{
                    backendData[i].productPrice = '';
                }
            }
            console.log('backendData ==> ', backendData);
            this.productsData = backendData;
            console.log('productsData ==> ', this.productsData);
            this.initialData = [...this.productsData];
                this.updateTotalPages();
                this.paginateData();
        })
        .catch(error => {
            console.log('In error' +error);
            console.error('Error occurred:', error);
            console.log('error in product data -- ', JSON.stringify(error));
        });
    }

    // @wire(getProductsForDistributor,{currentUserId:'$userId'})
    //  getProductData({error, data}) {
    //     if (error) {
    //         console.log('Error getting product data - ', error);
    //     } else if (data) {
    //         this.productsData = JSON.parse(JSON.stringify(data));
    //         console.log('Products data - ', JSON.stringify(this.productsData));
    //     }
    // }

    // Trial and error method
    handleRowSelection(event){
        var selRows = JSON.parse(JSON.stringify(event.detail.selectedRows));
        // console.log('selRows ==> ',JSON.stringify(selRows));
        if(selRows.length > this.selectedProducts.length){
            const IdsOfSelectRows = new Set(this.selectedProducts.map(item => item.Id));
            selRows.forEach(item => {
                if (!IdsOfSelectRows.has(item.Id)) {
                  this.selectedProducts.push(item);
                }
            });
            console.log('SelectedRows == ', JSON.stringify(this.selectedProducts));
        }else{
            
            const filteredRows = this.selectedProducts.filter(itemA => selRows.some(itemB => itemB.Id === itemA.Id));
            //console.log('Filtered rows',JSON.stringify(filteredRows));
            this.selectedProducts = filteredRows;
            console.log('this.selectedRows = ', JSON.stringify(this.selectedProducts));

        }
    }

    // 

    handleNext(){
        var el = this.template.querySelector('lightning-datatable');
        // console.log(el);
        var selected = el.getSelectedRows();
        console.log(selected);
        console.log('Next ==> ', JSON.stringify(this.selectedProducts));
        if(this.selectedProducts.length > 0){
            // this.selectedProducts = selected;
            this.page1 = false;
            this.preSelectedRows = [];
            selected.forEach((object, index) => {
                this.preSelectedRows.push(object.Id);
            });
            console.log('this.preSelectedRows --',JSON.stringify(this.preSelectedRows));
            console.log('this.preSelectedRows --',this.preSelectedRows);
        }else{
            // console.log('Error, No product is selected.');
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select atleast 1 product!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        
    }

    handleBackToPage1(){
        this.page1 = true;
        console.log('Back == ', JSON.stringify(this.selectedProducts));
    }

    handleQuantityChange(event){
        let currentIndex = event.target.dataset.id;
        // console.log('selected data before - ', this.selectedProducts);
        // console.log(this.selectedProducts[currentIndex]);

        var temp = this.selectedProducts;
        temp[currentIndex]['AskedQuantity'] = event.target.value;
        console.log('AskedQuantity - ',temp[currentIndex]['AskedQuantity']);
        this.globalAskedQuantity = temp[currentIndex]['AskedQuantity'];
    
        console.log('AskedQuantity - ', this.globalAskedQuantity);
        this.selectedProducts = temp;
        console.log('selected data after - ',JSON.stringify(this.selectedProducts));

    }

    handleSubmit(){
        var callCreatePurchaseOrder = true;
        console.log('Final Data - ' + this.selectedProducts);
        this.selectedProducts.forEach((obj, index) => {
            if (obj.AskedQuantity <= 0 || obj.AskedQuantity === '' || obj.AskedQuantity === null || obj.AskedQuantity === undefined) {
                callCreatePurchaseOrder = false;
            }
        });
        console.log(' callCreatePurchaseOrder - - ', callCreatePurchaseOrder);
        if(callCreatePurchaseOrder == true){
            this.showSpinner = true;
            console.log('Before apex send -- ', JSON.stringify(this.selectedProducts));
            createPurchaseOrder({userId : userId, poLineItemsData : JSON.stringify(this.selectedProducts),askqauntity:this.globalAskedQuantity})
            .then(result => {
                console.log('Created successfully', result);
                const evt = new ShowToastEvent({
                    message: 'Purchase Order created Successfully!',
                    title: 'Success',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                const closeModelEvent = new CustomEvent("submitform");
                this.dispatchEvent(closeModelEvent);
                this.showSpinner = false;
            })
            .catch(error => {
                // TODO Error handling
                console.log('Error - ', error);
            
                this.showSpinner = false;
                this.errorMessage = error.body.pageErrors[0].message;
                console.log('this.errorMessage',error.body.pageErrors);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
        }else{
            const evt = new ShowToastEvent({
                message: 'Please fill valid quantity!',
                title: 'Error',
                variant: 'Error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        this.currentPage = 1;
        if (searchTerm) {
            this.productsData = this.initialData.filter(item =>
                Object.values(item).some(value =>
                    value && value.toString().toLowerCase().includes(searchTerm)
                )
            );
            const searchResultSize = this.productsData.length;
            this.pageSize = searchResultSize <= DEFAULT_PAGE_SIZE ? searchResultSize : DEFAULT_PAGE_SIZE;
            this.productsData = this.productsData.slice(0, this.pageSize);
    
        } else {
             this.page1 = true;       
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
            this.productsData = this.initialData.slice(startIndex, endIndex).map((item, index) => ({
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
        handlepageNext() {
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

}