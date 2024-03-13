import { LightningElement, wire, api } from 'lwc';
import getOrderItems from '@salesforce/apex/ProductSearchAddController.getOrderItems';
import updateOrderItems from '@salesforce/apex/ProductSearchAddController.updateOrderItems';
import { refreshApex } from '@salesforce/apex';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
export default class Orel_Order_Basket extends LightningElement {
    columns = [
        {label : 'Product Name', fieldName : 'ProductName'},
        {label : 'Item Template', fieldName : 'Item_Template'},
        {label : 'Quantity', fieldName : 'Quantity', editable: true},
        {label : 'Price', fieldName : 'Price'},
        {label : 'Discount', fieldName : 'Discount'},
        {label : 'Value', fieldName : 'Value'},
    ]

    orderItems
    @api recordId
    visibleRecords
    fldsItemValues
    selection = []
    orderItemsMap = new Map();
    showAddProducts
    itemsPresent = false
    wireGetOrderItemsResult
    disableEdit = true

    @wire(getOrderItems, {orderId : '$recordId'})
    itemHandler(result){
        this.wireGetOrderItemsResult = result;
        const{data,error} = result
        if(data){
            console.log(data);
            console.log('recordId in basket::'+this.recordId);
            if(data.length){
                this.itemsPresent = true;
            }
            this.dataRecords = data.map(item=>{
                return {
                    'Id' : item.Id,
                    'ProductName' : item.cgcloud__Product__r.Name,
                    'Item_Template': item.cgcloud__Order_Item_Template__c?item.cgcloud__Order_Item_Template__r.Name : '',
                    'Price':item.cgcloud__Price__c,
                    'Quantity':item.cgcloud__Quantity__c,
                    'Discount':item.cgcloud__Discount__c,
                    'Value':item.cgcloud__Value__c
                }
            });
            this.orderItems = [...this.dataRecords];
            console.log('dataRecords::');
            console.log('dataRecords::'+this.dataRecords);
        }
        if(error){
            console.error(error);
        }     
    }

    clickHandler(event){
        console.log('add products button clicked on basket::')
        this.showAddProducts = true;
    }

    editHandler(event){
        console.log('JSON.stringify(this.orderItemsMap)::'+JSON.stringify(this.orderItemsMap));
        updateOrderItems({itemsMap : JSON.stringify(this.orderItemsMap), orderId : this.recordId})
        .then(result => {
            console.log('basket success::');
            refreshApex(this.wireGetOrderItemsResult);
            this.selection = [];
            this.fldsItemValues = [];
            this.disableEdit = true;
            notifyRecordUpdateAvailable([{recordId: this.selection}]);
            notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            console.log('after notifying lds of record change::')
        }).catch(error => {
            console.log(error);
        })
    }

     cancelHandler(event){
        refreshApex(this.wireGetOrderItemsResult);
            this.selection = [];
            this.fldsItemValues = [];
            this.disableEdit = true;
    }

    keyUpHandler(event){
        this.disableEdit = false;
    }

    saveHandler(event){
        console.log('event.detail.draftValues::'+event.detail.draftValues[0].Id)
        console.log('event.detail.draftValues::'+event.detail.draftValues[0].Quantity)
        //console.log('event.detail.draftValues::'+event.detail.draftValues[1].Id)
        //console.log('event.detail.draftValues::'+event.detail.draftValues[1].Quantity)
        //this.fldsItemValues = event.detail.draftValues;
        //console.log('this.orderItemsMap::'+this.orderItemsMap.size)
        console.log('JSON.stringify(this.orderItemsMap)::'+JSON.stringify(this.orderItemsMap));
        updateOrderItems({itemsMap : JSON.stringify(this.orderItemsMap), orderId : this.recordId})
        .then(result => {
            console.log('success::');
            this.fldsItemValues = [];
        }).catch(error => {
            console.log(error);
        })
    }

    closeModalHandler(event){
        console.log('close modal Handler entered::')
        this.showAddProducts = false;
         refreshApex(this.wireGetOrderItemsResult);
         notifyRecordUpdateAvailable([{recordId: this.selection}]);
            notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            console.log('after notifying lds of record change in close::')
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
        this.disableEdit = false;
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