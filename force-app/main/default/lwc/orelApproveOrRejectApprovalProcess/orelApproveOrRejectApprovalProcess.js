import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getoppdata from '@salesforce/apex/orelapprovalprocessclass.getoppdata';
import getopplineitemdata from '@salesforce/apex/orelapprovalprocessclass.getopplineitemdata';
import approverecord from '@salesforce/apex/orelapprovalprocessclass.approverecord';
import holdInventory from '@salesforce/apex/orelapprovalprocessclass.holdInventory';
import rejectrecord from '@salesforce/apex/orelapprovalprocessclass.rejectrecord';
import getstatus from '@salesforce/apex/orelapprovalprocessclass.getstatus';
import Id from "@salesforce/user/Id";
export default class OrelApproveOrRejectApprovalProcess extends LightningElement {
    userId = Id;
    @api recordId;
    @track opportunity;
    @track error;
    @track opportunitylineitem;
    @track recordstatus;
    urlId;
    data;
    openModal=false;
    @track isdisabled=false;
    @track isRejectModalOpen = false;
    @track reason;
    proid=[];
    inventory;
    @track columns = [{ label: 'Product Name', fieldName: 'Name' },
                      { label: 'Quantity', fieldName: 'Quantity' },
                      { label: 'Unit Price', fieldName: 'UnitPrice',type: 'currency', cellAttributes: { alignment: 'left' } },
                      { label: 'Total Price', fieldName: 'TotalPrice',type: 'currency', cellAttributes: { alignment: 'left' } },
                      { label: 'Current Distributor Inventory', fieldName: 'DistributorInventory' }];


    @track oppId;
    

    connectedCallback() {
        if(this.recordId)
        {   this.userId = Id;
            this.loadOppDetails();
            this.loadOpplineitemDetail();
         
           // this.getstatusdetail();
           console.log('parent rec Id'+this.recordId);
        }
        
    }
    loadOppDetails() {
        console.log('recId', this.recordId);
        getoppdata({ oppId: this.recordId })
            .then(result => {
                this.opportunity = result;
                console.log('Opportunity record', result);
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            });
    }
   
// Method to fetch OpportunityLineItem details
    // loadOpplineitemDetail() {
    //    // console.log('recId' +this.urlId);
    //     getopplineitemdata({oppId: this.recordId })
    //         .then(result => {   
    //             this.opportunitylineitem = result.map((item,ind)=>({
    //                 ...item,
    //                 Name:item.Product2.Name,
    //                 Quantity:item.Quantity,
    //                 UnitPrice:item.UnitPrice,
    //                 TotalPrice:item.TotalPrice,
    //                 CloseDate:item.CloseDate,
                   
    //             }));
    //             this.proid=item.Product2Id;
    //             console.log('proid',this.proid);
    //             this.getinventory();
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             console.log('errors', error);
    //         });
    // }

    // getInventory() {
    //     console.log('getInventory');
    //     holdInventory({ prodId: this.proid })
    //         .then(result => {
    //             this.inventory = result.map(item => ({
    //                 ...item
                    
    //             }));
    //             console.log('inventory',this.inventory);
             
    //         })
    //         .catch(error => {
    //             console.log('getInventory error');
    //             this.error = error;
    //             console.log('errors', error);
    //         });
    // }
    loadOpplineitemDetail() {
        getopplineitemdata({ oppId: this.recordId })
            .then(result => {   
                this.opportunitylineitem = result.map((item, ind) => ({
                    ...item,
                    Name: item.Product2.Name,
                    Quantity: item.Quantity,
                    UnitPrice: item.UnitPrice,
                    TotalPrice: item.TotalPrice,
                    CloseDate: item.CloseDate,
                    DistributorInventory:0
                   
                }));
                console.log('result',result);
               this.proid = result.map(item => item.Product2Id);
               console.log('proid',JSON.stringify(this.proid));
            this.getInventory();
            })
            .catch(error => {
                this.error = error;
                console.log('errors', error);
            });
    }
    @track DistributorInventory;
        getInventory() {
            holdInventory({userId:this.userId,prodId:this.proid})
                .then(result => {
                    result.forEach(item => {
                        let oppProduct = this.opportunitylineitem.find(opp => opp.Product2Id === item.cgcloud__Product__c);
                        if(oppProduct){
                            oppProduct.DistributorInventory = item.cgcloud__Balance__c;
                        }
                    })

                    
                    this.opportunitylineitem = [...this.opportunitylineitem]
                })
                .catch(error => {
                    console.log('getInventory error:', error);
                    this.error = error;
                });
        }
    
    
//     getInventory() {
//         holdInventory()
//             .then(result => {
//               this.inventory = result.map((e)=>e.cgcloud__Balance__c)  ;
//              const newArray= this.inventory.map(inventoryItem => {
//     const matchedItem = this.opportunitylineitem.find(oppItem => this.compareByProductId(inventoryItem, oppItem));
//     if (matchedItem) {
//         return { 
//             productId: inventoryItem.cgcloud__Product__c,          
//             productName: oppItem.Product2.Name,
//             quantityInOpportunity: matchedItem.quantity
//         };
//     } else {
//         return null; // Or any default value you prefer for non-matching items
//     }
// }).filter(item => item !== null);             
//             })
//             .catch(error => {
//                 console.log('getInventory error:', error);
//                 this.error = error;
//             });
//     }
// compareByProductId(item1, item2) {
//     return item1.cgcloud__Product__c === item2.Product2Id;
// }
   
    handleApprove() 
    {
        console.log('Opportunity Id:', this.recordId);
        if (this.recordId) {
            approverecord({ oppId: this.recordId})
                .then(result => {
                    this.showToast('Success', 'Record approved successfully', 'success');
                    console.log('Record approved:', result);
                     this.isdisabled=true;
                })
                .catch(error => {
                   
                    this.error = error;
                    this.showToast('Error', 'Error approving record', 'error');
                console.log('Error approving record:', error);
        
                });
        }

    }
    closeModal()
    {
        this.openModal=false;
    }

    handleReject(){
        this.openModal = true;

    }

    textdata(event)
    {
        this.data=event.target.value; 
    }
    handleRejectSubmit() {
        console.log('reason', this.data );
        console.log('Opportunity:',this.recordId);
        if (this.recordId)
         {
            rejectrecord({ oppId: this.recordId ,data:this.data })
                .then(result => {
                    this.showToast('Success', 'Record rejected successfully', 'success');
                    console.log('Record rejected:', result);
                    this.isdisabled=true;
                })
                .catch(error => {
                    // Handle errors
                    this.error=error;
                    this.showToast('Error', 'Error rejecting record', 'error');
                    console.error('Error rejecting record:', error);
                });
        }
        setTimeout(()=>
        {
            this.openModal=false;

        },500)
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
 
}