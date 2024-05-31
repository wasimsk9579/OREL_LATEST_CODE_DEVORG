import { LightningElement, wire } from 'lwc';
import getProductsForDistributor from '@salesforce/apex/OrlDistributorCreatePOController.getProductsForDistributor';
import IMAGES from "@salesforce/resourceUrl/Cart_Icon";
import userId from '@salesforce/user/Id';

export default class Orelproductcart extends LightningElement {
    products = [];
    imageLabel = 'Product Image';
    recordIdVal;
    disabledButtons = new Set();
    myimage = IMAGES + "/cart_image/carts.png";
    selectrecords = [];
    newQuantity ='';
    quantity =null;
    cartId;
    showProductList=true;
    

    connectedCallback() {
        console.log('userID -- ', userId);
        getProductsForDistributor({ currentUserId: userId })
            .then(result => {
                this.products = result.map(product => ({
                    Id: product.Id,
                    Name: product.Name,
                    ImageUrl: this.extractImageUrl(product.Image__c),
                    PricebookEntries: product.PricebookEntries
                }));
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
    handleQuantityChange(event){
        this.newQuantity = parseInt(event.target.value);
    }



    handleAddToCart(event) { 
             this.recordIdVal = event.target.value;
             
             this.quantity += 1;
           
             var quant = {
                 recordId: this.recordIdVal,
                 quantities : this.newQuantity
             };
            this.selectrecords.push(quant);
             console.log('Updated Cart Items: ', JSON.stringify(this.selectrecords));
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
            console.log('hiiii');
         //  this.showProductList = false;
        // console.log('this is in viewcart',JSON.stringify(this.selectrecords));
        //  let newCartArray = [];
        // for(let i = 0; i < this.selectrecords.length; i++) {
        //     newCartArray.push(this.selectrecords[i]);
        // }
        // this.cartId = newCartArray;
        // console.log('this is newcartarray'+JSON.stringify(this.cartId))
        // console.log('Updated Cart Items1: ', JSON.stringify(this.selectrecords));
        }
     
    }