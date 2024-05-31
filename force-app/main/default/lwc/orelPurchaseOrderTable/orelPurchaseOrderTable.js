 

// import { LightningElement, wire, track } from 'lwc';
// import compoinv from '@salesforce/apex/OrlDistributorCreatePOController.compoinv';
// import getProductsForDistributor from '@salesforce/apex/OrlDistributorCreatePOController.getProductsForDistributor';
// import createOppAndOppLineItems from '@salesforce/apex/OrlDistributorCreatePOController.createOppAndOppLineItems';
// import getcartCategoryProducts from '@salesforce/apex/OrlDistributorCreatePOController.getcartCategoryProducts';
// import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import IMAGES from "@salesforce/resourceUrl/Cart_Icon";
// const DEFAULTCART_PAGE_SIZE = 9;
// const DEFAULTCART_CATEGORY_SIZE = 9;
// import Id from '@salesforce/user/Id';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import CreatePurchaseOrderCss from '@salesforce/resourceUrl/CreatePurchaseOrderCss';
// import getoppordata from '@salesforce/apex/OrelPurchaseOrderTableController.getoppordata';
// const DEFAULT_PAGE_SIZE = 10; 

// export default class OrelPurchaseOrderTable extends LightningElement {
    

  
    
//     categorypagesize = DEFAULTCART_CATEGORY_SIZE;
    
//     userId; // A property to store the current user's Id retrieved from @salesforce/user/Id.
//     allData = []; // An array to store the retrieved data from the Apex method.
//     initialData = []; // A copy of allData to store the initial data for filtering purposes.
//     @track currentPage = 1; 
//     totalPages = 1;
//     @track pageSize = DEFAULT_PAGE_SIZE;
//     @track isLastPage = false; // A boolean variable to determine if the current page is the last page.
//     @track variable = false; 
//     accountstatus = true
//     showLoader = true;
//     isShowModal = false;
//     cateprocategory;
//     isNew = false;
//     isbgverified;
//     @track filteredCartProducts = [];
//    @track category = [];
//     cateid;
//    proid=[];
   
 
//     @track products = [];
//     imageLabel = 'Product Image';
//     recordIdVal;
//     myimage = IMAGES + "/cart_image/carts.png";
//     selectrecords = [];
//     newQuantity ='';
//     quantity =null;
//     cartId;
//     showProductList=true;
//     productName;
//     productImage;
//     @track selectedRecords=[]
//    @track globalBalance = 0;
//    productId;
//    showMessage='';
//    initialCartData=[];
//    totalCartPages = 1;
  
//  @track isCartLastPage = false; //
//    pageCartSize = DEFAULTCART_PAGE_SIZE;
//    @track currentCartPage = 1;
//    showProductList=false;
//    cartshowProductList=false;
//    iscreditlimit;
//    totalamount;
//    proinv;
//   mesaagearay=[];


//    @track showCartList = false;
//    @track categoryproduct = [];
//    @track cateprod = [];
//    @track cateinitialdata = [];
//    @track paginatedCategoryProducts = [];
//    @track currentcategryPage = 1;
//    @track totalCategoryPages = 1;

//     columns = [
       
//         { label: 'Name', fieldName: 'Name' },
//         { label: 'Amount', fieldName: 'Amount', type: 'currency', cellAttributes: { alignment: 'left' } },
//         { label: 'StageName', fieldName: 'StageName' },
//         { label: 'Ordered Date', fieldName: 'CreatedDate', type: 'date', sortable: true },
//         {
//             label: 'Action',
//             type: 'button',
//             typeAttributes: {
//                 label: 'View More',
//                 title: 'Click here',
//                 variant: 'brand',
//                 name: 'view_details'
//             },
//         }
//     ];
    

//     connectedCallback() {
//         this.userId = Id;
//         this.callApexMethod();
        

//         Promise.all([

//             loadStyle( this, CreatePurchaseOrderCss )

//             ]).then(() => {

//                 console.log( 'Files loaded CreatePurchaseOrderCss' );

//             })

//             .catch(error => {

//                 console.log( error.body.message );

//         });
      
//     }

//     callApexMethod() {
//         getoppordata({ userIds: this.userId })
//             .then(result => { 
//                 console.log('result data',result);
//                 console.log('record' +JSON.stringify(result));   
//                 this.allData=result;
//                 this.allData.forEach(item => {
//                     if (item.Account && item.Account.Deboarding_process_status__c === 'In Process - Working with Reconciliation & Full and Final Settlement') {
//                         this.isNew = true;
//                     }
//                     console.log('Deboarding_process_status__c:', item.Account ? item.Account.Deboarding_process_status__c : 'N/A');
//                     this.isNew = item.Account ? item.Account.Deboarding_process_status__c === 'In Process - Working with Reconciliation & Full and Final Settlement' : false; 
//                     this.isbgverified=item.Account.orl_BG_Verified__c,
//                     this.iscreditlimit=item.Account.Credit_Limit__c,
//                     console.log('this.iscreditlimit',this.iscreditlimit);
//                 });

                
//                 console.log('56',this.isNew);
//                 this.initialData = [...this.allData];
//                 this.updateTotalPages();
//                 this.paginateData();
//                 this.showLoader = false;
//                 this.variable = false;
//                 this.showProductList=false;
//                 this.cartshowProductList=false;
//                 this. isShowModal = false;
//             })
//             .catch(error => {
//                 console.error('Error fetching data:', error);            
//             });
//     }
//     onHandleSort(event) {
//         const { fieldName: sortedBy, sortDirection } = event.detail;p
//         const cloneData = [...this.allData];
//         cloneData.sort((a, b) => {
//             return this.sortBy(a, b, sortedBy, sortDirection);
//         });
//         this.allData = cloneData;
//         this.sortDirection = sortDirection;
//         this.sortedBy = sortedBy;
//     }
// // sortBy: A helper method used in sorting the data.
//         sortBy(a, b, fieldName, sortDirection) {
//             const valueA = a[fieldName];
//             const valueB = b[fieldName];
//             let comparison = 0;   

//             if (valueA === valueB) {
//                 comparison = a.index > b.index ? 1 : a.index < b.index ? -1 : 0;
//             } else if (typeof valueA === 'string' && typeof valueB === 'string') {
//                 comparison = valueA.toLowerCase().localeCompare(valueB.toLowerCase());
//             } else if (!isNaN(valueA) && !isNaN(valueB)) {
//                 comparison = parseFloat(valueA) - parseFloat(valueB);
//             }
//             return sortDirection === 'asc' ? comparison : -comparison;
//         }

// // handleSearch: A method to handle searching/filtering of the data based on user input.

// handleSearch(event) {
//     const searchTerm = event.target.value.toLowerCase();
//     this.currentPage = 1;
//     if (searchTerm) {
//         this.allData = this.initialData.filter(item =>
//             Object.values(item).some(value =>
//                 value && value.toString().toLowerCase().includes(searchTerm)
//             )
//         );
//         const searchResultSize = this.allData.length;
//         this.pageSize = searchResultSize <= DEFAULT_PAGE_SIZE ? searchResultSize : DEFAULT_PAGE_SIZE;
//         this.allData = this.allData.slice(0, this.pageSize);

//     } else {
//          this.variable = false;       
//          this.paginateData();
//     }    
// }

// // updateTotalPages: A method to calculate the total number of pages based on the data size and page size.

//     updateTotalPages() {
//               this.totalPages = Math.ceil(this.initialData.length / DEFAULT_PAGE_SIZE);
//     }
// // paginateData: A method to slice and display the data based on the current page and page size
//     paginateData() {
//         const startIndex = (this.currentPage - 1) * DEFAULT_PAGE_SIZE;
//         const endIndex = startIndex + DEFAULT_PAGE_SIZE;
//         this.allData = this.initialData.slice(startIndex, endIndex).map((item, index) => ({
//             ...item,
//             index: startIndex + index + 1,
//         }));
//     }
// // handlePrevious and handleNext: Methods to navigate to the previous and next pages.    
//     handlePrevious() {
//         if (this.currentPage > 1) {
//             this.currentPage--;
//             this.paginateData();
//         }
//     }    
//     handleNext() {
//         if (this.currentPage < this.totalPages) {
//             this.currentPage++;
//             this.paginateData();
//         }
//     }
// // isFirstPage and isLastPage: Computed properties to check if the current page is the first or last page.    
//     get isFirstPage() {
//         return this.currentPage === 1;
//     }

//     get isLastPage() {
//         return this.currentPage === this.totalPages;
//     }

//     handleRowAction(event) {
//         console.log('row action -- ', JSON.stringify(event.detail.row.Id));
//         var recId = event.detail.row.Id;
//         console.log('id' +recId);
//         this.clickedoppId = recId;
//         this.variable = true;
//         console.log('OUTPUT parent: ', this.clickedoppId);
//     }
//     handleBackToReturnList()
//     {
//         this.variable = false;

//     }
//     showToast(title, message, variant) {
//         const event = new ShowToastEvent({
//             title: title,
//             message: message,
//             variant: variant
//         });
//         this.dispatchEvent(event);
//     }
//     handleOpenPopup()
//     {
//         if(this.isbgverified==false)
//         {
//             this.showToast("BG Verified Is Expired.Can't Create Purchase Order","","info");
//             return;
//         }
        
//        else if (!this.isNew){
//             this.isShowModal = true;
//             this.showProductList=false;
//             this.cartshowProductList = false;
//             this.showCartList=true;
//         }

//         this.callcateMethod();

//     }

//     closeModalPopup() 
//     {
//         this.isShowModal = false;
//         // this.refreshData();
//     }






// callcateMethod() {
//     getcartCategoryProducts()
//         .then(result => {
//             console.log('result--->', JSON.stringify(result));
//             this.categoryproduct = result.map(product => ({
//                 Id: product.Id,
//                 Name: product.Name,
//                 Code:product.Category_code__c,
//                 // ImageUrl: this.extraccarttImageUrl(product.Category_Image__c),
//             }));
//             console.log('categoryproduct', JSON.stringify(this.categoryproduct));
//             this.cateprod = [...this.categoryproduct];
//             this.cateinitialdata = [...this.categoryproduct];
//             console.log('Processed cart result', JSON.stringify(this.cateprod));
//             this.updateCategoryTotalPages();
//             this.paginatecategoryData();
//         })
//         .catch(error => {
//             console.error('Error fetching product data: ', error);
//         });
// }

// // extraccarttImageUrl(htmlContent) {
// //     let imageUrl = null;
// //     console.log('htmlContent-->'+htmlContent);
// //     if (htmlContent) {
        
// //         // const imgRegex = /<img.*?src=['"](.*?)['"].*?>/g;
// //         // const match = imgRegex.exec(htmlContent);
// //         // if (match && match.length > 1) {
// //         //     imageUrl = match[1]; // Extracted image URL
// //         // }
        
// //         let tempDiv = document.createElement('div');
// //         tempDiv.innerHTML = htmlContent;
// //         let imgElement = tempDiv.querySelector('img');
// //         if (imgElement) {
// //             imageUrl = imgElement.getAttribute('src');
            
// //         }
// //     }
// //     console.log('imageUrl-->'+imageUrl);
// //     return imageUrl;
// // }

// handleCategorySearch(event) {
//     const searchTerm = event.target.value.toLowerCase();
//     console.log('searchTerm category', searchTerm);
//     this.currentcategryPage = 1;
//     if (searchTerm) {
//         this.cateprod = this.categoryproduct.filter(item =>
//             Object.values(item).some(value =>
//                 value && value.toString().toLowerCase().includes(searchTerm)
//             )
//         );
//     } else {
//         this.cateprod = [...this.categoryproduct];
//     }
//     this.updateCategoryTotalPages();
//     this.paginatecategoryData();
// }

// updateCategoryTotalPages() {
//     this.totalCategoryPages = Math.ceil(this.cateprod.length / DEFAULTCART_CATEGORY_SIZE);
// }

// paginatecategoryData() {
//     const startIndex = (this.currentcategryPage - 1) * DEFAULTCART_CATEGORY_SIZE;
//     const endIndex = startIndex + DEFAULTCART_CATEGORY_SIZE;
//     this.paginatedCategoryProducts = this.cateprod.slice(startIndex, endIndex).map((item, index) => ({
//         ...item,
//         index: startIndex + index + 1,
//     }));
// }

// handleCategoryPrevious() {
//     if (this.currentcategryPage > 1) {
//         this.currentcategryPage--;
//         this.paginatecategoryData();
//     }
// }

// handlecategoryNext() {
//     if (this.currentcategryPage < this.totalCategoryPages) {
//         this.currentcategryPage++;
//         this.paginatecategoryData();
//     }
// }

// get iscategoryFirstPage() {
//     return this.currentcategryPage === 1;
// }

// get isCategoryLastPage() {
//     return this.currentcategryPage === this.totalCategoryPages;
// }
























    


//         handleButtonClick(event) {

//     // Attempt to get the recordId from the event
//     const recordId = event.target.value;
//     console.log('recid', JSON.stringify( event.target.value));
      
//         this.cateid=recordId;
//         console.log('Record ID:', this.cateid);
//      this.showcartdata();
//     }




//     // category product code////////////////////////////////////////////////////////////////////////////////
//         showcartdata() {
//            console.log('showcartdata',this.userId);
//             getProductsForDistributor({ currentUserId: this.userId,catid:this.cateid })
//                 .then(result => {
//                     this.products = result.map(product => ({
//                         Id: product.Id,
//                         Name: product.Name,
//                         ImageUrl: this.extractImageUrl(product.Image__c),
//                         PricebookEntries: product.PricebookEntries,
//                         Quantity : 0,
//                        TotalPrice : 0,
//                        showAddMessage: false
//                     }));
//                     this.filteredCartProducts = [...this.products]  
//                     this.initialCartData = [...this.products];
//                     this.updateCartTotalPages();
//                     this.paginateCartData();
//                     console.log('result', this.products);
//                     this.showProductList=true;
//                     this.showCartList=false;
//                     if (this.mesaagearay.length > 0) {
//                         this.mesaagearay.forEach(productId => {
//                             let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
//                             if (matchedProduct) {
//                                 matchedProduct.showAddMessage = true;
//                             }
//                         });
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }else{
//                         this.filteredCartProducts = [...this.products]  
//                     }
//                 })
//                 .catch(error => {
//                     console.error('Error fetching product data: ', error);
//                 });
//         }
    
//         extractImageUrl(htmlContent) {
//             console.log('hiii');
//             let imageUrl = null;
//             if (htmlContent) {
//                 let tempDiv = document.createElement('div');
//                 tempDiv.innerHTML = htmlContent;
//                 let imgElement = tempDiv.querySelector('img');
//                 if (imgElement) {
//                     imageUrl = imgElement.getAttribute('src');
//                 }
//             }
//             return imageUrl;
//         }
     
    
        
//         handleproductQuantityChange(event) {
//             this.productId = event.target.dataset.id;
//             const inpValue=event.target.value;
//             console.log('inpValue--'+inpValue);
//           console.log('this.productId', this.productId);
//             const selectedProduct = this.filteredCartProducts.find(product => product.Id === event.target.dataset.id);
//             if (selectedProduct) {
//                 selectedProduct.Quantity = event.target.value;
//                 console.log('selectedProduct.Quantity',selectedProduct.Quantity);
//                 const priceEntry = selectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
//                 if (priceEntry) {
//                     selectedProduct.TotalPrice = event.target.value * priceEntry.UnitPrice;
//                 }
//                 this.filteredCartProducts = [...this.filteredCartProducts];
//             }
//             this.updateProducts();
          
//         }
       
       
        
//         updateProducts() {
//     return compoinv({ proId: this.productId })
//         .then(result => {
//             console.log('755', JSON.stringify(result));
//             if (result && result.length > 0) {
//                 this.proinv = result[0].cgcloud__Balance__c;
//             } else {
//                 this.proinv = 0; // Set proinv to 0 if result is null or empty
//             }
//             console.log('336', this.proinv);
//         })
//         .catch(error => {
//             console.error('Error fetching product inventory:', error);
//             this.proinv = 0; // Optionally set proinv to 0 in case of an error as well
//         });
// }

        
//         showToast(title, message, variant) {
//             const event = new ShowToastEvent({
//                 title: title,
//                 message: message,
//                 variant: variant
//             });
//             this.dispatchEvent(event);
       
//     }
//     @track productIndex;
//     @track selectedProduct;
//         handleAddToCart(event) {
             
//                 const selectedProduct = this.filteredCartProducts.find(product => product.Id === event.target.value);
//                 if(selectedProduct.Quantity<=0|| !selectedProduct.Quantity)
//                 {
//                     this.showToast("Please Add Qauntity","","info");
//                     return;
//                 }
//                 else if(selectedProduct.Quantity > this.proinv)
//                 {
//                     this.showToast("Quanity is More Than Product Inventory","","info");
//                     return;
//                 }
//                 console.log('selectedProduct',JSON.stringify(selectedProduct));
               
//                 if(selectedProduct){
                  
//                     const alreadyExistingProductInCart = this.selectedRecords ? this.selectedRecords.find(product => product.Id === selectedProduct.Id) : NULL;
//                     console.log('HII',JSON.stringify(alreadyExistingProductInCart));
//                     if(alreadyExistingProductInCart){
//                         alreadyExistingProductInCart.Quantity =  selectedProduct.Quantity;
    
//                         this.selectedRecords = [...this.selectedRecords];
                        
//                         console.log('IF',JSON.stringify(this.selectedRecords));
//                     }else{
//                         this.selectedRecords.push(selectedProduct);
//                         console.log('ELSE',JSON.stringify(this.selectedRecords));
//                     }
//                     const filteredProductArray = [...this.filteredCartProducts];
//                     const productId = event.target.value;
//                     this.productIndex = event.target.dataset.index;
//                     console.log('this.productIndex',this.productIndex );
//                     this.filteredCartProducts[this.productIndex].showAddMessage = true; 
//                     this.filteredCartProducts = [...this.filteredCartProducts];
//                     console.log('filteredCartProducts add to cart -- ' + JSON.stringify(this.filteredCartProducts));
//                     this.selectedProduct = selectedProduct;
//                     console.log('392',JSON.stringify(this.selectedProduct));
//                     this.mesaagearay.push(selectedProduct.Id);
//                     console.log('this.mesaagearay',JSON.stringify(this.mesaagearay));


//                 } 

              
//                 }
                
 
    
//             //  incrementQuantity(event){
//             //     const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
           
//             //     // If the item exists in the cart
//             //     if (index !== -1) {
//             //         // Increase the quantity of the item
//             //         this.selectrecords[index].quantities += 1;
//             //     } else {
//             //         // If the item doesn't exist in the cart, add it with quantity 1
//             //         const newItem = {
//             //             recordId: event.target.value,
//             //             quantities: 1
//             //         };
//             //         this.selectrecords.push(newItem);
//             //     }
           
//             //     // Increase the total quantity
//             //     this.quantity += 1;
//             //     console.log('quantity:', this.quantity);
//             //     console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
         
//             // }
    
//             // decrementQuantity(event){
//             //     const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
           
//             //     // If the item exists in the cart
//             //     if (index !== -1) {
//             //         // Decrease the quantity of the item
//             //         this.selectrecords[index].quantities -= 1;
           
//             //         // If the quantity becomes 0, remove the item from the cart
//             //         if (this.selectrecords[index].quantities === 0) {
//             //             this.selectrecords.splice(index, 1);
//             //         }
//             //     }
           
//             //     // Decrease the total quantity
//             //     this.quantity -= 1;
//             //     console.log('quantity:', this.quantity);
//             //     console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
    
//             // }
    
         
//             viewCart(){       
//             this.cartshowProductList = true;
//             this.showProductList = false;
//             console.log('this is in viewcart',JSON.stringify(this.selectedRecords));
           
//             }
//             handleBack() {
//                 this.showProductList = true;
//                 this.cartshowProductList = false; // Set showProductList to true when Back button is clicked.

//             }
//             handleshowcartBack()
//             {
//                 this.showProductList = false;
//                 this.cartshowProductList = false; 
//                 this.variable = false;
//                 this.showProductList = false;

//                 this.isShowModal = false;
//                 location.reload();
//             }

//             handleshowcategoryBack()
//             {
//                 this.showProductList = false;
//                 this.showCartList=true;

               
              
//             }

//             handlecartQuantityChange(event) {
//                 const productId = event.target.dataset.id;
//                 // const newQuantity = parseInt(event.target.value, 10); // Parse input value to integer
//                 const newQuantity = event.target.value;
//                 const cartselectedProductIndex = this.selectedRecords.findIndex(product => product.Id === productId);
            
//                 if (cartselectedProductIndex !== -1) {
//                     const cartselectedProduct = this.selectedRecords[cartselectedProductIndex];
//                     cartselectedProduct.Quantity = newQuantity; // Update Quantity
            
//                     // Update Total Price
//                     const priceEntry = cartselectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
//                     if (priceEntry) {
//                         cartselectedProduct.TotalPrice = newQuantity * priceEntry.UnitPrice;
//                     }
            
//                     // Update selectedRecords array
//                     this.selectedRecords = [...this.selectedRecords];
//                     console.log('Updated selectedRecords: ', JSON.stringify(this.selectedRecords));
//                 }
//                 this.calculateTotalPrice();
//             }
//             calculateTotalPrice() {
//                 this.totalPriceSum = this.selectedRecords.reduce((sum, product) => sum + product.TotalPrice, 0);
//             }
        
//             removeProduct(event) {
//                 const productId = event.target.dataset.id;
//                 this.selectedRecords = this.selectedRecords.filter(product => product.Id !== productId);
//                 this.calculateTotalPrice();
//                 console.log('remove',this.selectedRecords );
//             }

//             get totalPriceSum() {
//                 let sum = 0;
//                 this.selectedRecords.forEach(record => {
//                     sum += record.TotalPrice;
//                     this.totalamount=sum;
                    
//                 });
//                 return sum;
                
//             }
    
//             handleCartSearch(event) {
//                 const searchTerm = event.target.value.toLowerCase();
//                 console.log('searchTerm',searchTerm);
//                 this.currentCartPage = 1;
//                 if (searchTerm) {
//                     this.filteredCartProducts = this.products.filter(item =>
//                         Object.values(item).some(value =>
//                             value && value.toString().toLowerCase().includes(searchTerm)
//                         )
//                     );
//                     const searchResultSize = this.filteredCartProducts.length;
//                     this.pageCartSize = searchResultSize <= DEFAULTCART_PAGE_SIZE ? searchResultSize : DEFAULTCART_PAGE_SIZE;
//                     if (this.mesaagearay.length > 0) {
//                         this.mesaagearay.forEach(productId => {
//                             let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
//                             if (matchedProduct) {
//                                 matchedProduct.showAddMessage = true;
//                             }
//                         });
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }else{
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }
//                     this.filteredCartProducts = this.filteredCartProducts.slice(0, this.pageCartSize);
            
//                 } else {
//                     if (this.mesaagearay.length > 0) {
//                         this.mesaagearay.forEach(productId => {
//                             let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
//                             if (matchedProduct) {
//                                 matchedProduct.showAddMessage = true;
//                             }
//                         });
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }else{
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }
//                     this.filteredCartProducts = [...this.products]
//                   //  this.showProductList = true;       
//                  //  this.paginateCartData();
//                 }    
//             }
    
    
//              // updateCartTotalPages: A method to calculate the total number of pages based on the data size and page size.
    
//         updateCartTotalPages() {
//             this.totalCartPages = Math.ceil(this.initialCartData.length / DEFAULTCART_PAGE_SIZE);
//     }
//     // paginateCartData: A method to slice and display the data based on the current page and page size
//     paginateCartData() {
//       const startIndex = (this.currentCartPage - 1) * DEFAULTCART_PAGE_SIZE;
//       const endIndex = startIndex + DEFAULTCART_PAGE_SIZE;

//       console.log('this.mesaagearay-->'+this.mesaagearay);

//         // Ensure reactivity by updating the array reference
//         this.filteredCartProducts = this.initialCartData.slice(startIndex, endIndex).map((item, index) => ({
//             ...item,
//             index: startIndex + index + 1,
//         }));
  
      
//     }

//     paginateCartPreviousData() {
//         const startIndex = (this.currentCartPage - 1) * DEFAULTCART_PAGE_SIZE;
//         const endIndex = startIndex + DEFAULTCART_PAGE_SIZE;
  
//         this.filteredCartProducts = this.initialCartData.slice(startIndex, endIndex).map((item, index) => ({
//             ...item,
//             index: startIndex + index + 1,
//         }));
        
//       }
    
//     // handlePrevious and handleNext: Methods to navigate to the previous and next pages.    
//     handleCartPrevious(event) {
//         if (this.currentCartPage > 1) {
//             this.currentCartPage--;
//             this.paginateCartPreviousData();
//             // console.log('filteredCartProducts previous -- ' + JSON.stringify(this.selectedProduct));
//             // console.log('filteredCartProducts previous 122 -- ' + JSON.stringify(this.filteredCartProducts));
//             // const productIndexVal = this.selectedRecords ? this.selectedRecords.find(product => product.Id === this.selectedProduct.Id) : NULL;
//             // console.log('productIndexVal --->',productIndexVal);
//             // this.filteredCartProducts[this.selectedProduct.Id].showAddMessage = true; 
//                     // this.filteredCartProducts = [...this.filteredCartProducts];
//                     // this.selectedProduct.forEach(selectedProd => {
//                     //     // Find the matching product in filteredCartProducts by Id
//                     //     let matchedProduct = this.filteredCartProducts.find(cartProd => cartProd.Id === selectedProd.Id);
//                     //     // If a matching product is found, set showAddMessage to true
//                     //     if (matchedProduct) {
//                     //       matchedProduct.showAddMessage = true;
//                     //     }
//                     //   });

//                       //this.filteredCartProducts = [...this.filteredCartProducts];
//                       if (this.mesaagearay.length > 0) {
//                         this.mesaagearay.forEach(productId => {
//                             let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
//                             if (matchedProduct) {
//                                 matchedProduct.showAddMessage = true;
//                             }
//                         });
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }else{
//                         this.filteredCartProducts = [...this.filteredCartProducts];
//                     }
            
//         }
//       }    
//       handleCartNext() {
//         if (this.currentCartPage < this.totalCartPages) {
//             this.currentCartPage++;
//             this.paginateCartData();
//             if (this.mesaagearay.length > 0) {
//                 this.mesaagearay.forEach(productId => {
//                     let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
//                     if (matchedProduct) {
//                         matchedProduct.showAddMessage = true;
//                     }
//                 });
//                 this.filteredCartProducts = [...this.filteredCartProducts];
//             }else{
//                 this.filteredCartProducts = [...this.filteredCartProducts];
//             }

//         }
//       }
//       // isFirstPage and isLastPage: Computed properties to check if the current page is the first or last page.    
//       get isCartFirstPage() {
//         return this.currentCartPage === 1;
//       }
      
//       get isCartLastPage() {
//         return this.currentCartPage === this.totalCartPages;
//       }

//       showToast(title, message, variant) {
//         const event = new ShowToastEvent({
//             title: title,
//             message: message,
//             variant: variant
//         });
//         this.dispatchEvent(event);
   
// }

   

 
      
//     handleCheckout() {
//         if (this.iscreditlimit < this.totalamount) {
//             this.showToast("Purchase Order Amount Is More Than Distributor or DD Credit limit", "", "info");
//             return;
//         } else {
//             console.log('You can create PO');
//             const selectedRecordsJson = JSON.stringify(this.selectedRecords);
//             console.log('selectedRecordsJson', selectedRecordsJson);
    
//             const selectedRecords = JSON.parse(selectedRecordsJson);
//             console.log('selectedRecords', JSON.stringify(selectedRecords));
    
//             const extractedData = selectedRecords.map(record => {
//                 const product2Id = record.Id;
//                 const quantity = record.Quantity;
//                 const unitPrice = record.PricebookEntries[0].UnitPrice; // Assuming there's only one PricebookEntry
//                 return {
//                     Product2Id: product2Id,
//                     Quantity: quantity,
//                     UnitPrice: unitPrice
//                 };
//             });
    
//             console.log('extractedData', JSON.stringify(extractedData));
    
//             const quantities = this.selectedRecords.map(record => record.Quantity);
    
//             createOppAndOppLineItems({
//                     userId: this.userId,
//                     poLineItemsData: selectedRecordsJson,
//                     askQuantity: quantities,
//                     listOfObjects: extractedData
//                 })
//                 .then(result => {
//                     console.log('Created successfully', result);
//                     const evt = new ShowToastEvent({
//                         message: 'Purchase Order created Successfully!',
//                         title: 'Success',
//                         variant: 'success',
//                         mode: 'dismissable'
//                     });
//                     this.dispatchEvent(evt);
//                     setTimeout(() => {
//                         console.log('Reloading page...');
//                         location.reload();
//                     }, 2000);
//                 })
//                 .catch(error => {
//                     console.log('Error - ', error);
//                     let errorMessage = 'An error occurred while creating the Purchase Order.';
//                     if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
//                         errorMessage = error.body.pageErrors[0].message;
//                     }
//                     const evt = new ShowToastEvent({
//                         title: 'Error',
//                         message: errorMessage,
//                         variant: 'error',
//                         mode: 'dismissable'
//                     });
//                     this.dispatchEvent(evt);
//                 });
//         }
//     }
// }




import { LightningElement, wire, track } from 'lwc';
import compoinv from '@salesforce/apex/OrlDistributorCreatePOController.compoinv';
import getProductsForDistributor from '@salesforce/apex/OrlDistributorCreatePOController.getProductsForDistributor';
import createOppAndOppLineItems from '@salesforce/apex/OrlDistributorCreatePOController.createOppAndOppLineItems';
import getcartCategoryProducts from '@salesforce/apex/OrlDistributorCreatePOController.getcartCategoryProducts';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import IMAGES from "@salesforce/resourceUrl/Cart_Icon";
const DEFAULTCART_PAGE_SIZE = 9;
const DEFAULTCART_CATEGORY_SIZE = 25;
import Id from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import CreatePurchaseOrderCss from '@salesforce/resourceUrl/CreatePurchaseOrderCss';
import getoppordata from '@salesforce/apex/OrelPurchaseOrderTableController.getoppordata';
const DEFAULT_PAGE_SIZE = 10; 

export default class OrelPurchaseOrderTable extends LightningElement {
    

  
    
    categorypagesize = DEFAULTCART_CATEGORY_SIZE;
    
    userId; // A property to store the current user's Id retrieved from @salesforce/user/Id.
    allData = []; // An array to store the retrieved data from the Apex method.
    initialData = []; // A copy of allData to store the initial data for filtering purposes.
    @track currentPage = 1; 
    totalPages = 1;
    @track pageSize = DEFAULT_PAGE_SIZE;
    @track isLastPage = false; // A boolean variable to determine if the current page is the last page.
    @track variable = false; 
    accountstatus = true
    showLoader = true;
    isShowModal = false;
    cateprocategory;
    isNew = false;
    isbgverified;
    @track filteredCartProducts = [];
   @track category = [];
    cateid;
   proid=[];
   
 
    @track products = [];
    imageLabel = 'Product Image';
    recordIdVal;
    myimage = IMAGES + "/cart_image/carts.png";
    selectrecords = [];
    newQuantity ='';
    quantity =null;
    cartId;
    showProductList=true;
    productName;
    productImage;
    @track selectedRecords=[]
   @track globalBalance = 0;
   productId;
   showMessage='';
   initialCartData=[];
   totalCartPages = 1;
  
 @track isCartLastPage = false; //
   pageCartSize = DEFAULTCART_PAGE_SIZE;
   @track currentCartPage = 1;
   showProductList=false;
   cartshowProductList=false;
   iscreditlimit;
   totalamount;
   proinv;
  mesaagearay=[];


   @track showCartList = false;
   @track categoryproduct = [];
   @track cateprod = [];
   @track cateinitialdata = [];
   @track paginatedCategoryProducts = [];
   @track currentcategryPage = 1;
   @track totalCategoryPages = 1;

    columns = [
       
        { label: 'Name', fieldName: 'Name' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency', cellAttributes: { alignment: 'left' } },
        { label: 'StageName', fieldName: 'StageName' },
        { label: 'Ordered Date', fieldName: 'CreatedDate', type: 'date', sortable: true },
        {
            label: 'Action',
            type: 'button',
            typeAttributes: {
                label: 'View More',
                title: 'Click here',
                variant: 'brand',
                name: 'view_details'
            },
        }
    ];
    

    connectedCallback() {
        this.userId = Id;
        this.callApexMethod();
        

        Promise.all([

            loadStyle( this, CreatePurchaseOrderCss )

            ]).then(() => {

                console.log( 'Files loaded CreatePurchaseOrderCss' );

            })

            .catch(error => {

                console.log( error.body.message );

        });
      
    }

    callApexMethod() {
        getoppordata({ userIds: this.userId })
            .then(result => { 
                console.log('result data',result);
                console.log('record' +JSON.stringify(result));   
                this.allData=result;
                this.allData.forEach(item => {
                    if (item.Account && item.Account.Deboarding_process_status__c === 'In Process - Working with Reconciliation & Full and Final Settlement') {
                        this.isNew = true;
                    }
                    console.log('Deboarding_process_status__c:', item.Account ? item.Account.Deboarding_process_status__c : 'N/A');
                    this.isNew = item.Account ? item.Account.Deboarding_process_status__c === 'In Process - Working with Reconciliation & Full and Final Settlement' : false; 
                    this.isbgverified=item.Account.orl_BG_Verified__c,
                    this.iscreditlimit=item.Account.Credit_Limit__c,
                    console.log('this.iscreditlimit',this.iscreditlimit);
                });

                
                console.log('56',this.isNew);
                this.initialData = [...this.allData];
                this.updateTotalPages();
                this.paginateData();
                this.showLoader = false;
                this.variable = false;
                this.showProductList=false;
                this.cartshowProductList=false;
                this. isShowModal = false;
            })
            .catch(error => {
                console.error('Error fetching data:', error);            
            });
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;p
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

    handleRowAction(event) {
        console.log('row action -- ', JSON.stringify(event.detail.row.Id));
        var recId = event.detail.row.Id;
        console.log('id' +recId);
        this.clickedoppId = recId;
        this.variable = true;
        console.log('OUTPUT parent: ', this.clickedoppId);
    }
    handleBackToReturnList()
    {
        this.variable = false;

    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    handleOpenPopup()
    {
        if(this.isbgverified==false)
        {
            this.showToast("BG Verified Is Expired.Can't Create Purchase Order","","info");
            return;
        }
        
       else if (!this.isNew){
            this.isShowModal = true;
            this.showProductList=false;
            this.cartshowProductList = false;
            this.showCartList=true;
        }

        this.callcateMethod();

    }

    closeModalPopup() 
    {
        this.isShowModal = false;
        // this.refreshData();
    }






callcateMethod() {
    getcartCategoryProducts()
        .then(result => {
            console.log('result--->', JSON.stringify(result));
            this.categoryproduct = result.map(product => ({
                Id: product.Id,
                Name: product.Name,
                Code:product.Category_code__c,
                // ImageUrl: this.extraccarttImageUrl(product.Category_Image__c),
            }));
            console.log('categoryproduct', JSON.stringify(this.categoryproduct));
            this.cateprod = [...this.categoryproduct];
            this.cateinitialdata = [...this.categoryproduct];
            console.log('Processed cart result', JSON.stringify(this.cateprod));
            this.updateCategoryTotalPages();
            this.paginatecategoryData();
        })
        .catch(error => {
            console.error('Error fetching product data: ', error);
        });
}

// extraccarttImageUrl(htmlContent) {
//     let imageUrl = null;
//     console.log('htmlContent-->'+htmlContent);
//     if (htmlContent) {
        
//         // const imgRegex = /<img.*?src=['"](.*?)['"].*?>/g;
//         // const match = imgRegex.exec(htmlContent);
//         // if (match && match.length > 1) {
//         //     imageUrl = match[1]; // Extracted image URL
//         // }
        
//         let tempDiv = document.createElement('div');
//         tempDiv.innerHTML = htmlContent;
//         let imgElement = tempDiv.querySelector('img');
//         if (imgElement) {
//             imageUrl = imgElement.getAttribute('src');
            
//         }
//     }
//     console.log('imageUrl-->'+imageUrl);
//     return imageUrl;
// }

handleCategorySearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    console.log('searchTerm category', searchTerm);
    this.currentcategryPage = 1;
    if (searchTerm) {
        this.cateprod = this.categoryproduct.filter(item =>
            Object.values(item).some(value =>
                value && value.toString().toLowerCase().includes(searchTerm)
            )
        );
    } else {
        this.cateprod = [...this.categoryproduct];
    }
    this.updateCategoryTotalPages();
    this.paginatecategoryData();
}

updateCategoryTotalPages() {
    this.totalCategoryPages = Math.ceil(this.cateprod.length / DEFAULTCART_CATEGORY_SIZE);
}

@track paginatedCategoryProducts = [];
    @track cateprod = []; // Ensure cateprod is populated with your data
    @track currentcategryPage = 1;
    @track selectedCategory;

    paginatecategoryData() {
        const startIndex = (this.currentcategryPage - 1) * DEFAULTCART_CATEGORY_SIZE;
        const endIndex = startIndex + DEFAULTCART_CATEGORY_SIZE;
        this.paginatedCategoryProducts = this.cateprod.slice(startIndex, endIndex).map((item, index) => ({
            ...item,
            index: startIndex + index + 1,
        }));
        console.log('+++++++++++++' + this.paginatedCategoryProducts);
    }

    get categoryOptions() {
        return this.paginatedCategoryProducts.map(category => ({
            label: category.Name,
            value: category.Id,
        }));
    }
     handleChange(event) {
        this.selectedCategory = event.detail.value;
        console.log('Selected Category:', this.selectedCategory);
      
        this.cateid=this.selectedCategory;
        console.log('Record ID:', this.cateid);
     this.showcartdata();
    }

handleCategoryPrevious() {
    if (this.currentcategryPage > 1) {
        this.currentcategryPage--;
        this.paginatecategoryData();
    }
}

handlecategoryNext() {
    if (this.currentcategryPage < this.totalCategoryPages) {
        this.currentcategryPage++;
        this.paginatecategoryData();
    }
}

get iscategoryFirstPage() {
    return this.currentcategryPage === 1;
}

get isCategoryLastPage() {
    return this.currentcategryPage === this.totalCategoryPages;
}
























    


        handleButtonClick(event) {

    // Attempt to get the recordId from the event
    const recordId = event.target.value;
    console.log('recid', JSON.stringify( event.target.value));
      
        this.cateid=recordId;
        console.log('Record ID:', this.cateid);
     this.showcartdata();
    }




    // category product code////////////////////////////////////////////////////////////////////////////////
        showcartdata() {
           console.log('showcartdata',this.userId);
            getProductsForDistributor({ currentUserId: this.userId,catid:this.cateid })
                .then(result => {
                    this.products = result.map(product => ({
                        Id: product.Id,
                        Name: product.Name,
                        ImageUrl: this.extractImageUrl(product.Image__c),
                        PricebookEntries: product.PricebookEntries,
                        Quantity : 0,
                       TotalPrice : 0,
                       showAddMessage: false
                    }));
                    this.filteredCartProducts = [...this.products]  
                    this.initialCartData = [...this.products];
                    this.updateCartTotalPages();
                    this.paginateCartData();
                    console.log('result', this.products);
                    this.showProductList=true;
                    //this.showCartList=false;
                    if (this.mesaagearay.length > 0) {
                        this.mesaagearay.forEach(productId => {
                            let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
                            if (matchedProduct) {
                                matchedProduct.showAddMessage = true;
                            }
                        });
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }else{
                        this.filteredCartProducts = [...this.products]  
                    }
                })
                .catch(error => {
                    console.error('Error fetching product data: ', error);
                });
        }
    
        extractImageUrl(htmlContent) {
            console.log('hiii');
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
     
    
        
        handleproductQuantityChange(event) {
            this.productId = event.target.dataset.id;
            const inpValue=event.target.value;
            console.log('inpValue--'+inpValue);
          console.log('this.productId', this.productId);
            const selectedProduct = this.filteredCartProducts.find(product => product.Id === event.target.dataset.id);
            if (selectedProduct) {
                selectedProduct.Quantity = event.target.value;
                console.log('selectedProduct.Quantity',selectedProduct.Quantity);
                const priceEntry = selectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
                if (priceEntry) {
                    selectedProduct.TotalPrice = event.target.value * priceEntry.UnitPrice;
                }
                this.filteredCartProducts = [...this.filteredCartProducts];
            }
            this.updateProducts();
          
        }
       
       
        
        updateProducts() {
    return compoinv({ proId: this.productId })
        .then(result => {
            console.log('755', JSON.stringify(result));
            if (result && result.length > 0) {
                this.proinv = result[0].cgcloud__Balance__c;
            } else {
                this.proinv = 0; // Set proinv to 0 if result is null or empty
            }
            console.log('336', this.proinv);
        })
        .catch(error => {
            console.error('Error fetching product inventory:', error);
            this.proinv = 0; // Optionally set proinv to 0 in case of an error as well
        });
}

        
        showToast(title, message, variant) {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(event);
       
    }
    @track productIndex;
    @track selectedProduct;
        handleAddToCart(event) {
             
                const selectedProduct = this.filteredCartProducts.find(product => product.Id === event.target.value);
                if(selectedProduct.Quantity<=0|| !selectedProduct.Quantity)
                {
                    this.showToast("Please Add Qauntity","","info");
                    return;
                }
                else if(selectedProduct.Quantity > this.proinv)
                {
                    this.showToast("Quanity is More Than Product Inventory","","info");
                    return;
                }
                console.log('selectedProduct',JSON.stringify(selectedProduct));
               
                if(selectedProduct){
                  
                    const alreadyExistingProductInCart = this.selectedRecords ? this.selectedRecords.find(product => product.Id === selectedProduct.Id) : NULL;
                    console.log('HII',JSON.stringify(alreadyExistingProductInCart));
                    if(alreadyExistingProductInCart){
                        alreadyExistingProductInCart.Quantity =  selectedProduct.Quantity;
    
                        this.selectedRecords = [...this.selectedRecords];
                        
                        console.log('IF',JSON.stringify(this.selectedRecords));
                    }else{
                        this.selectedRecords.push(selectedProduct);
                        console.log('ELSE',JSON.stringify(this.selectedRecords));
                    }
                    const filteredProductArray = [...this.filteredCartProducts];
                    const productId = event.target.value;
                    this.productIndex = event.target.dataset.index;
                    console.log('this.productIndex',this.productIndex );
                    this.filteredCartProducts[this.productIndex].showAddMessage = true; 
                    this.filteredCartProducts = [...this.filteredCartProducts];
                    console.log('filteredCartProducts add to cart -- ' + JSON.stringify(this.filteredCartProducts));
                    this.selectedProduct = selectedProduct;
                    console.log('392',JSON.stringify(this.selectedProduct));
                    this.mesaagearay.push(selectedProduct.Id);
                    console.log('this.mesaagearay',JSON.stringify(this.mesaagearay));


                } 

              
                }
                
 
    
            //  incrementQuantity(event){
            //     const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
           
            //     // If the item exists in the cart
            //     if (index !== -1) {
            //         // Increase the quantity of the item
            //         this.selectrecords[index].quantities += 1;
            //     } else {
            //         // If the item doesn't exist in the cart, add it with quantity 1
            //         const newItem = {
            //             recordId: event.target.value,
            //             quantities: 1
            //         };
            //         this.selectrecords.push(newItem);
            //     }
           
            //     // Increase the total quantity
            //     this.quantity += 1;
            //     console.log('quantity:', this.quantity);
            //     console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
         
            // }
    
            // decrementQuantity(event){
            //     const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
           
            //     // If the item exists in the cart
            //     if (index !== -1) {
            //         // Decrease the quantity of the item
            //         this.selectrecords[index].quantities -= 1;
           
            //         // If the quantity becomes 0, remove the item from the cart
            //         if (this.selectrecords[index].quantities === 0) {
            //             this.selectrecords.splice(index, 1);
            //         }
            //     }
           
            //     // Decrease the total quantity
            //     this.quantity -= 1;
            //     console.log('quantity:', this.quantity);
            //     console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
    
            // }
    
         
            viewCart(){       
            this.cartshowProductList = true;
            this.showProductList = false;
            this.showCartList=false;
            console.log('this is in viewcart',JSON.stringify(this.selectedRecords));
           
            }
            handleBack() {
                this.showProductList = true;
                this.cartshowProductList = false;
                this.showCartList=true; 
                this.isShowModal=true;

            }
            handleshowcartBack()
            {
                this.showProductList = false;
                this.cartshowProductList = false; 
                this.variable = false;
                this.showProductList = false;

                this.isShowModal = false;
                location.reload();
            }

            handleshowcategoryBack()
            {
                this.showProductList = false;
                this.showCartList=true;

               
              
            }

            handlecartQuantityChange(event) {
                const productId = event.target.dataset.id;
                // const newQuantity = parseInt(event.target.value, 10); // Parse input value to integer
                const newQuantity = event.target.value;
                const cartselectedProductIndex = this.selectedRecords.findIndex(product => product.Id === productId);
            
                if (cartselectedProductIndex !== -1) {
                    const cartselectedProduct = this.selectedRecords[cartselectedProductIndex];
                    cartselectedProduct.Quantity = newQuantity; // Update Quantity
            
                    // Update Total Price
                    const priceEntry = cartselectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
                    if (priceEntry) {
                        cartselectedProduct.TotalPrice = newQuantity * priceEntry.UnitPrice;
                    }
            
                    // Update selectedRecords array
                    this.selectedRecords = [...this.selectedRecords];
                    console.log('Updated selectedRecords: ', JSON.stringify(this.selectedRecords));
                }
                this.calculateTotalPrice();
            }
            calculateTotalPrice() {
                this.totalPriceSum = this.selectedRecords.reduce((sum, product) => sum + product.TotalPrice, 0);
            }
        
            removeProduct(event) {
                const productId = event.target.dataset.id;
                this.selectedRecords = this.selectedRecords.filter(product => product.Id !== productId);
                this.calculateTotalPrice();
                console.log('remove',this.selectedRecords );
            }

            get totalPriceSum() {
                let sum = 0;
                this.selectedRecords.forEach(record => {
                    sum += record.TotalPrice;
                    this.totalamount=sum;
                    
                });
                return sum;
                
            }
    
            handleCartSearch(event) {
                const searchTerm = event.target.value.toLowerCase();
                console.log('searchTerm',searchTerm);
                this.currentCartPage = 1;
                if (searchTerm) {
                    this.filteredCartProducts = this.products.filter(item =>
                        Object.values(item).some(value =>
                            value && value.toString().toLowerCase().includes(searchTerm)
                        )
                    );
                    const searchResultSize = this.filteredCartProducts.length;
                    this.pageCartSize = searchResultSize <= DEFAULTCART_PAGE_SIZE ? searchResultSize : DEFAULTCART_PAGE_SIZE;
                    if (this.mesaagearay.length > 0) {
                        this.mesaagearay.forEach(productId => {
                            let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
                            if (matchedProduct) {
                                matchedProduct.showAddMessage = true;
                            }
                        });
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }else{
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }
                    this.filteredCartProducts = this.filteredCartProducts.slice(0, this.pageCartSize);
            
                } else {
                    if (this.mesaagearay.length > 0) {
                        this.mesaagearay.forEach(productId => {
                            let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
                            if (matchedProduct) {
                                matchedProduct.showAddMessage = true;
                            }
                        });
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }else{
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }
                    this.filteredCartProducts = [...this.products]
                  //  this.showProductList = true;       
                 //  this.paginateCartData();
                }    
            }
    
    
             // updateCartTotalPages: A method to calculate the total number of pages based on the data size and page size.
    
        updateCartTotalPages() {
            this.totalCartPages = Math.ceil(this.initialCartData.length / DEFAULTCART_PAGE_SIZE);
    }
    // paginateCartData: A method to slice and display the data based on the current page and page size
    paginateCartData() {
      const startIndex = (this.currentCartPage - 1) * DEFAULTCART_PAGE_SIZE;
      const endIndex = startIndex + DEFAULTCART_PAGE_SIZE;

      console.log('this.mesaagearay-->'+this.mesaagearay);

        // Ensure reactivity by updating the array reference
        this.filteredCartProducts = this.initialCartData.slice(startIndex, endIndex).map((item, index) => ({
            ...item,
            index: startIndex + index + 1,
        }));
  
      
    }

    paginateCartPreviousData() {
        const startIndex = (this.currentCartPage - 1) * DEFAULTCART_PAGE_SIZE;
        const endIndex = startIndex + DEFAULTCART_PAGE_SIZE;
  
        this.filteredCartProducts = this.initialCartData.slice(startIndex, endIndex).map((item, index) => ({
            ...item,
            index: startIndex + index + 1,
        }));
        
      }
    
    // handlePrevious and handleNext: Methods to navigate to the previous and next pages.    
    handleCartPrevious(event) {
        if (this.currentCartPage > 1) {
            this.currentCartPage--;
            this.paginateCartPreviousData();
            // console.log('filteredCartProducts previous -- ' + JSON.stringify(this.selectedProduct));
            // console.log('filteredCartProducts previous 122 -- ' + JSON.stringify(this.filteredCartProducts));
            // const productIndexVal = this.selectedRecords ? this.selectedRecords.find(product => product.Id === this.selectedProduct.Id) : NULL;
            // console.log('productIndexVal --->',productIndexVal);
            // this.filteredCartProducts[this.selectedProduct.Id].showAddMessage = true; 
                    // this.filteredCartProducts = [...this.filteredCartProducts];
                    // this.selectedProduct.forEach(selectedProd => {
                    //     // Find the matching product in filteredCartProducts by Id
                    //     let matchedProduct = this.filteredCartProducts.find(cartProd => cartProd.Id === selectedProd.Id);
                    //     // If a matching product is found, set showAddMessage to true
                    //     if (matchedProduct) {
                    //       matchedProduct.showAddMessage = true;
                    //     }
                    //   });

                      //this.filteredCartProducts = [...this.filteredCartProducts];
                      if (this.mesaagearay.length > 0) {
                        this.mesaagearay.forEach(productId => {
                            let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
                            if (matchedProduct) {
                                matchedProduct.showAddMessage = true;
                            }
                        });
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }else{
                        this.filteredCartProducts = [...this.filteredCartProducts];
                    }
            
        }
      }    
      handleCartNext() {
        if (this.currentCartPage < this.totalCartPages) {
            this.currentCartPage++;
            this.paginateCartData();
            if (this.mesaagearay.length > 0) {
                this.mesaagearay.forEach(productId => {
                    let matchedProduct = this.filteredCartProducts.find(product => product.Id == productId);
                    if (matchedProduct) {
                        matchedProduct.showAddMessage = true;
                    }
                });
                this.filteredCartProducts = [...this.filteredCartProducts];
            }else{
                this.filteredCartProducts = [...this.filteredCartProducts];
            }

        }
      }
      // isFirstPage and isLastPage: Computed properties to check if the current page is the first or last page.    
      get isCartFirstPage() {
        return this.currentCartPage === 1;
      }
      
      get isCartLastPage() {
        return this.currentCartPage === this.totalCartPages;
      }

      showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
   
}

   

 
      
    handleCheckout() {
        if (this.iscreditlimit < this.totalamount) {
            this.showToast("Purchase Order Amount Is More Than Distributor or DD Credit limit", "", "info");
            return;
        } else {
            console.log('You can create PO');
            const selectedRecordsJson = JSON.stringify(this.selectedRecords);
            console.log('selectedRecordsJson', selectedRecordsJson);
    
            const selectedRecords = JSON.parse(selectedRecordsJson);
            console.log('selectedRecords', JSON.stringify(selectedRecords));
    
            const extractedData = selectedRecords.map(record => {
                const product2Id = record.Id;
                const quantity = record.Quantity;
                const unitPrice = record.PricebookEntries[0].UnitPrice; // Assuming there's only one PricebookEntry
                return {
                    Product2Id: product2Id,
                    Quantity: quantity,
                    UnitPrice: unitPrice
                };
            });
    
            console.log('extractedData', JSON.stringify(extractedData));
    
            const quantities = this.selectedRecords.map(record => record.Quantity);
    
            createOppAndOppLineItems({
                    userId: this.userId,
                    poLineItemsData: selectedRecordsJson,
                    askQuantity: quantities,
                    listOfObjects: extractedData
                })
                .then(result => {
                    console.log('Created successfully', result);
                    const evt = new ShowToastEvent({
                        message: 'Purchase Order created Successfully!',
                        title: 'Success',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    setTimeout(() => {
                        console.log('Reloading page...');
                        location.reload();
                    }, 2000);
                })
                .catch(error => {
                    console.log('Error - ', error);
                    let errorMessage = 'An error occurred while creating the Purchase Order.';
                    if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
                        errorMessage = error.body.pageErrors[0].message;
                    }
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                });
        }
    }
}