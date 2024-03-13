import { LightningElement, wire, api } from 'lwc';
import getProducts from '@salesforce/apex/ProductSearchAddController.getProducts';
import createOrderItems from '@salesforce/apex/ProductSearchAddController.createOrderItems';
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
export default class Orel_Search_Product extends NavigationMixin(LightningElement) {

    columns = [
        {label : 'Product Name', fieldName : 'ProductName'},
        {label : 'Product Description', fieldName : 'Description'},
        {label : 'Product Code', fieldName : 'Product_Code'},
        {label : 'Product Template', fieldName : 'Product_Template'},
        {label : 'Quantity', fieldName : 'Quantity', editable: true}
    ]
    @api recordId
    prodRecords
    dataRecords
    visibleRecords
    searchKeys
    fldsItemValues = []
    selection =[]
    orderItemsMap = new Map();
    orderItem
    baseUrl

    @wire(getProducts)
    productHandler({data, error}){
        if(data){
            console.log(data);
            this.dataRecords = data.map(prod=>{
                return {
                    'Id' : prod.Id,
                    'ProductName' : prod.Name,
                    'Description' : prod.Description,
                    'Product_Code': prod.ProductCode,
                    'Product_Template': prod.cgcloud__Product_Template__c?prod.cgcloud__Product_Template__r.Name:'',
                    'Quantity':''
                }
            });
            this.prodRecords = [...this.dataRecords];
            console.log('dataRecords::');
            console.log('dataRecords::'+this.dataRecords);
        }
        if(error){
            console.error(error);
        }     
    }

    handleSearch(event){
        console.log('search entered::')
        console.log('this.searchKeys.pname::',this.searchKeys.pname);
        this.prodRecords = this.dataRecords.filter(prod => {
                                //this.searchKeys.pname!==undefined? return prod.ProductName.includes(this.searchKeys.pname) : return true
                                return this.filterSearch(prod);
                            });
        console.log('this.prodRecords::'+this.prodRecords);   
    }

    filterSearch(prod){
        let a = true;
        let b = true;
        let c = true;
        if(this.searchKeys.pname!==undefined){
            a = prod.ProductName.toUpperCase().includes(this.searchKeys.pname.toUpperCase())
        }
        if(this.searchKeys.pcode!==undefined){
            b = prod.ProductName.includes(this.searchKeys.pcode)
        }
        if(this.searchKeys.ptemplate!==undefined){
            a = prod.ProductName.includes(this.searchKeys.ptemplate)
        }
        return a && b && c;
    }

    changeHandler(event){
        let {name, value} = event.target;
        console.log('name::'+name)
        console.log('value::'+value)
        this.searchKeys = {...this.searchKeys, [name]:value};
        console.log('this.searchKeys.pname::'+this.searchKeys.pname)
    }

    /*handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('actionName::'+actionName)
        console.log('row::'+row)
    }*/


    saveHandler(event){
        //this.dispatchEvent(new CloseActionScreenEvent());
        //window.location.reload();
        createOrderItems({itemsMap : JSON.stringify(this.orderItemsMap), orderId : this.recordId})
        .then(result => {
        this.baseUrl = window.location.origin + '/lightning/r/cgcloud__Order__c/'+ this.recordId + '/view'
            window.location.assign(this.baseUrl);
            // this.dispatchEvent(new CloseActionScreenEvent());
             //window.location.reload();
            // this.dispatchEvent(new CloseActionScreenEvent()); 
        }).catch(error => {
            console.log(error);
        })
    }

    cellChangeHandler(event){
       //let draftValues = this.template.querySelector('lightning-datatable').draftValues;
       console.log('cell change handler entered::') 
        console.log('event.detail.draftValues Id::'+event.detail.draftValues[0].Id)
        console.log('event.detail.draftValues Quantity::'+event.detail.draftValues[0].Quantity)
        const {Id,Quantity} = event.detail.draftValues[0];
        console.log('beforeMap::')
        //this.orderItemsMap.set(Id,Quantity);
        this.orderItemsMap[Id] = Quantity;
        console.log('Quantity::'+this.orderItemsMap.get(Id))
        console.log('mapSize::'+this.orderItemsMap.size)
        console.log('orderItemsMap::'+this.orderItemsMap);
        console.log('selection::'+this.selection);
        if(!this.selection.includes(event.detail.draftValues[0].Id))
        {
            this.selection= [...this.selection, event.detail.draftValues[0].Id];
        }
        console.log('this.selection::'+this.selection);
    }

    updateHandler(event){
        this.visibleRecords=[...event.detail.records];
        this.template.querySelector('[data-id="datarow"]').selectedRows = this.selection;
        //console.log('data-id::');
        //console.log(this.template.querySelector('[data-id="datarow"]').selectedRows);
    }

    handleRowSelection(evt){
        // List of selected items from the data table event.
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selection);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();


        this.visibleRecords.map((event) => {
            loadedItemsSet.add(event.Id);
        });


        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Id);
            });


            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });        
        }


        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });


        this.selection = [...selectedItemsSet];
        console.log('Selection::');
        console.log(this.selection);
    }
}