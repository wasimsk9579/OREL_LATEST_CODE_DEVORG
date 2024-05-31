import { LightningElement, api } from 'lwc';
import getAccdata from '@salesforce/apex/oreldistdetailscontroller.getAccdata';
import Id from "@salesforce/user/Id";

export default class Oreldistdetails extends LightningElement {
    @api accData;
    userId = Id;

    formatAddress(address) {
        if (address) {
            const street = address.street ? `${address.street}` : '';
            const city = address.city ? ` ${address.city}` : '';
            const country = address.country ? `, ${address.country}` : '';
            const state = address.state ? `, ${address.state}` : '';
            const postalCode = address.postalCode ? `- ${address.postalCode}` : '';
            return `${street}${city}${state}${country}${postalCode}`;
        } else {
            return '';
        }
    }
    connectedCallback() {
        getAccdata({ userId: this.userId })
            .then(result => {
                // Format the Credit_Limit__c field value as currency
                if (result.Credit_Limit__c) {
                    result.Credit_Limit__c = this.formatCurrency(result.Credit_Limit__c, 'LKR');
                    result.BG_amount__c = this.formatCurrency(result.BG_amount__c, 'LKR');
                    result.distaddress=this.formatAddress(result.BillingAddress);
                }
                // Store the returned data in accData
                this.accData = result;
                console.log('Record: ' + JSON.stringify(this.accData));
            })
            .catch(error => {
                console.error('Error: ' + error);
            });
    }

    formatCurrency(amount, currency) {
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency }).format(amount);
    }
}