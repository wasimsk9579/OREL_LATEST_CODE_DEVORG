import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Orelnotificationicon extends LightningElement {

    @api recordId;
 
    redirectToOpportunity() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
}
