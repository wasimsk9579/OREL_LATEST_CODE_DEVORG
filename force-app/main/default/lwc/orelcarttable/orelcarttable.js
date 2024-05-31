import { LightningElement, wire, api } from 'lwc';
import getcartproduct from '@salesforce/apex/Orelcarttablecontroller.getcartproduct';
import userId from '@salesforce/user/Id';
export default class Orelcarttable extends LightningElement {
@api recId;
    products = [];
    imageLabel = 'Product Image';
    recordIdVal;
    disabledButtons = new Set();
    selectrecords = [];
    newQuantity ='';
    quantity =null;
    cartId;
    showProductList=true;
    productName;
    productImage;
    productId;
    Quantities;
    //productPrice;

    connectedCallback() {
        console.log('userID -- ', userId);
        console.log('this is transer', JSON.stringify(this.recId));
        this.Quantities=this.recId;
        if (this.recId) {
            this.proid = this.recId.map(item => item.Id); 
            console.log('proid', JSON.stringify(this.proid));
        }
        getcartproduct({productId:this.proid,currentUserId:userId})
            .then(result => {
                this.products = result.map(product => ({
                    Id: product.Id,
                    Name: product.Name,
                    ImageUrl: this.extractImageUrl(product.Image__c),
                    PricebookEntries: product.PricebookEntries,
                }));
                console.log('cart result', result);
                console.log('PricebookEntries',PricebookEntries[0].UnitPrice);
                console.log('TotalPrice',this.Quantities[0].Quantity*product.PricebookEntries);
                
            })
            .catch(error => {
                console.error('Error fetching product data: ', error);
            });
    }

    extractImageUrl(htmlContent) {
        let imageUrl = null;
        if (htmlContent) {
            let tempDiv = document.createElement('div');
            tempDiv.innerHTML = htmlContent;
            let imgElement = tempDiv.querySelector('img');
            if (imgElement) {
                imageUrl = imgElement.getAttribute('src');
            }
        }
        return imageUrl;
    }

}









//     @api recId;
//     quantity;
//     proids = []; // Change to an array

//     connectedCallback() {
//         console.log('this is transfer', JSON.stringify(this.recId));
        
//         if (this.recId) {
//             this.proids = this.recId.map(item => item.recordId);
//             console.log('proids', JSON.stringify(this.proids));
//             this.loadCartProducts();
//         }
//     }

//     // loadCartProducts() {
//     //     console.log('this.proids', JSON.stringify(this.proids));
//     //     getcartproduct({ prodId: this.proids.join(',') }) // Join array elements into a comma-separated string
//     //         .then(result => {
//     //             this.quantity = result;
//     //             console.log('cart result', this.quantity);
//     //         })
//     //         .catch(error => {
//     //            console.error('error', error);
//     //         });
//     // }



//     ///////////////////////////////////////////////////////////////////////////////////////////c/bundleDataTreeGrid
  
// data;
// error;
// contactId;

// isDriveAvailable;
// studentRegDriveId;
// isResult;
// isEligibleDrives = true;
// isSpinner = false;


//  @wire(getcartproduct)
// fetchAllEligibleDrive(result){
//     if(result.data){
//         this.data = result.data.map(drive => {
   
//             let companyName = {name : drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Company_Image__c ? drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Company_Image__c : (drive.Rpl_Placement_Drive__r && drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r) ? drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name : undefined, isImageRender : false};
            
//             let tempDiv = document.createElement('div');
//             tempDiv.innerHTML = companyName.name;

//             let imgElement = tempDiv.querySelector('img');

//             if (imgElement) {
//                 companyName.name = imgElement.getAttribute('src');
//                 console.log(companyName.name );
//                 companyName.isImageRender = true;
//             } else {
//                 console.log('img element not found.');
//             }

//            console.log('Company Name ' + JSON.stringify(companyName));
            

//             return {
//                 id: drive.Id,
              
//                 driveName: (drive.Rpl_Placement_Drive__r) ? drive.Rpl_Placement_Drive__r.Name : undefined,
//                 companyName,
// /*                 companyName: (drive.Rpl_Placement_Drive__r && drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r) ? drive.Rpl_Placement_Drive__r.Rpl_Company_Name__r.Name : undefined,
//  */             
               
//             };
//         });
//     }
//     else if(result.error){  
        
//         this.error= result.error;
//     }
// }
 
// }
