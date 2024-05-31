
import { LightningElement, wire, track } from 'lwc';
import compoinv from '@salesforce/apex/OrlDistributorCreatePOController.compoinv';
import getProductsForDistributor from '@salesforce/apex/OrlDistributorCreatePOController.getProductsForDistributor';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import IMAGES from "@salesforce/resourceUrl/Cart_Icon";
import userId from '@salesforce/user/Id';
const DEFAULTCART_PAGE_SIZE = 9; 
export default class Orelproductcart extends LightningElement {
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
   errormessage='';

   initialCartData=[];
   totalCartPages = 1;
 @track isCartLastPage = false; //
   pageCartSize = DEFAULTCART_PAGE_SIZE;
   @track currentCartPage = 1;
   

    connectedCallback() {
        console.log('userID -- ', userId);
        getProductsForDistributor({ currentUserId: userId })
            .then(result => {
                this.products = result.map(product => ({
                    Id: product.Id,
                    Name: product.Name,
                    ImageUrl: this.extractImageUrl(product.Image__c),
                    PricebookEntries: product.PricebookEntries,
                    Quantity : 0,
                   TotalPrice : 0
                }));
                this.showProductList = true;    
                this.initialCartData = [...this.products];
                this.updateCartTotalPages();
                this.paginateCartData();
                console.log('result', result);
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
 

    
    handleproductQuantityChange(event) {
        const selectedProduct = this.products.find(product => product.Id === event.target.dataset.id);
        if (selectedProduct) {
            selectedProduct.Quantity = event.target.value;
            console.log('selectedProduct.Quantity',selectedProduct.Quantity);
            const priceEntry = selectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
            if (priceEntry) {
                selectedProduct.TotalPrice = event.target.value * priceEntry.UnitPrice;
            }
            this.products = [...this.products];
        }
    }
   
    
    showMessage(event) {
        this.productId = event.target.dataset.id;
        console.log('this.productId', this.productId);
        
        this.updateProducts().then(() => {
            console.log('productsWithErrors');
            const productsWithErrors = this.products.map(product => ({
                ...product,
                showErrorMessage: product.Id === this.productId
            }));
            this.products = [...productsWithErrors];
        });
    }
    
    updateProducts() {
        return compoinv({proId:this.productId})
            .then(result => {
                console.log('755', JSON.stringify(result)); 
                console.log('idd',result[0].cgcloud__Balance__c);
              this.errormessage= 'Company inventory for this product is  '+result[0].cgcloud__Balance__c;     
            })
            
            .catch(error => {
                this.errormessage= ' No Company inventory for this product'
            });

            
    }
    
    
    hideMessage(event) {
        this.products = this.products.map(product => ({
            ...product,
            showErrorMessage: false
        }));
    }


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
   
}

    handleAddToCart(event) {
         
            const selectedProduct = this.products.find(product => product.Id === event.target.value);
            if(selectedProduct.Quantity<=0|| !selectedProduct.Quantity)
            {
                this.showToast("Please Add Qauntity","","info");
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
            } 
            }
            
       
    

         incrementQuantity(event){
            const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
       
            // If the item exists in the cart
            if (index !== -1) {
                // Increase the quantity of the item
                this.selectrecords[index].quantities += 1;
            } else {
                // If the item doesn't exist in the cart, add it with quantity 1
                const newItem = {
                    recordId: event.target.value,
                    quantities: 1
                };
                this.selectrecords.push(newItem);
            }
       
            // Increase the total quantity
            this.quantity += 1;
            console.log('quantity:', this.quantity);
            console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
     
        }

        decrementQuantity(event){
            const index = this.selectrecords.findIndex(item => item.recordId === event.target.value);
       
            // If the item exists in the cart
            if (index !== -1) {
                // Decrease the quantity of the item
                this.selectrecords[index].quantities -= 1;
       
                // If the quantity becomes 0, remove the item from the cart
                if (this.selectrecords[index].quantities === 0) {
                    this.selectrecords.splice(index, 1);
                }
            }
       
            // Decrease the total quantity
            this.quantity -= 1;
            console.log('quantity:', this.quantity);
            console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));

        }

     
        viewCart(){    
           
        this.showProductList = false;
        console.log('this is in viewcart',JSON.stringify(this.selectedRecords));
         let newCartArray = [];
        for(let i = 0; i < this.selectedRecords.length; i++) {
            newCartArray.push(this.selectedRecords[i]);
        }
        this.cartId = newCartArray;
        console.log('this is newcartarray'+JSON.stringify(this.cartId))
        console.log('Updated Cart Items1: ', JSON.stringify(this.selectedRecords));
        }
        handleBack() {
            this.showProductList = true; // Set showProductList to true when Back button is clicked.
        }

        handlecartQuantityChange(event)
        {
            const cartselectedProduct = this.selectedRecords.find(product => product.Id === event.target.dataset.id);
            console.log('cartselectedProduct',JSON.stringify(cartselectedProduct));
            if (cartselectedProduct) {
                cartselectedProduct.Quantity = event.target.value;
                console.log('cartselectedProduct.Quantity',cartselectedProduct.Quantity);
                const priceEntry = cartselectedProduct.PricebookEntries[0]; // Assuming there's only one PricebookEntry
                if (priceEntry) {
                    cartselectedProduct.TotalPrice = event.target.value * priceEntry.UnitPrice;
                }
                this.products = [...this.products];
            }
        }
        get totalPriceSum() {
            let sum = 0;
            this.selectedRecords.forEach(record => {
                sum += record.TotalPrice;
            });
            return sum;
        }

        handleCartSearch(event) {
            const searchTerm = event.target.value.toLowerCase();
            console.log('searchTerm',searchTerm);
            this.currentCartPage = 1;
            if (searchTerm) {
                this.products = this.products.filter(item =>
                    Object.values(item).some(value =>
                        value && value.toString().toLowerCase().includes(searchTerm)
                    )
                );
                const searchResultSize = this.products.length;
                this.pageCartSize = searchResultSize <= DEFAULTCART_PAGE_SIZE ? searchResultSize : DEFAULTCART_PAGE_SIZE;
                this.products = this.products.slice(0, this.pageCartSize);
        
            } else {
                this.showProductList = true;       
               this.paginateCartData();
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
  this.products = this.initialCartData.slice(startIndex, endIndex).map((item, index) => ({
      ...item,
      index: startIndex + index + 1,
  }));
}

// handlePrevious and handleNext: Methods to navigate to the previous and next pages.    
handleCartPrevious() {
    if (this.currentCartPage > 1) {
        this.currentCartPage--;
        this.paginateCartData();
    }
  }    
  handleCartNext() {
    if (this.currentCartPage < this.totalCartPages) {
        this.currentCartPage++;
        this.paginateCartData();
    }
  }
  // isFirstPage and isLastPage: Computed properties to check if the current page is the first or last page.    
  get isCartFirstPage() {
    return this.currentCartPage === 1;
  }
  
  get isCartLastPage() {
    return this.currentCartPage === this.totalCartPages;
  }




    }