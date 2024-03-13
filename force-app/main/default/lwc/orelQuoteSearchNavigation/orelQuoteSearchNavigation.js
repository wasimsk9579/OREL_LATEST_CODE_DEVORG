import { LightningElement, api } from "lwc";
import { NavigationMixin} from "lightning/navigation";
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';


export default class OrelQuoteSearchNavigation extends NavigationMixin( LightningElement) {



  @api recordId;
  handlebuttonclick(){
    const stateValues = encodeDefaultFieldValues({
        Name : 'Centimeter'
    });
    console.log('### record id from nav component--->',this.recordId)
    this[NavigationMixin.Navigate]({
        type : 'standard__navItemPage',
        attributes :{
            apiName : 'Quote_Search',
            recordId:this.recordId
        }
    })
}



handleNewbuttonclick(){
    const stateValues = encodeDefaultFieldValues({
        Name : 'Centimeter'
    });
    console.log('### record id from nav component--->',this.recordId)
    this[NavigationMixin.Navigate]({
        type : 'standard__navItemPage',
        attributes :{
            apiName : 'Search_Quote_Bundle',
            recordId:this.recordId
        }
    })
}   
}