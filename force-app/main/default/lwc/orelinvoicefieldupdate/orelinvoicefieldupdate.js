import { LightningElement, api } from 'lwc';
import updateinvoiceStatus from '@salesforce/apex/orlReturnOrderController.updateinvoiceStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Orelinvoicefieldupdate extends LightningElement {
    @api recordId;
    errorMessage = '';
    error;
    orderId;

    @api invoke() {
        console.log('Invoke method called');
        console.log('recordId:', this.recordId);

        if (this.recordId) {
            this.updatedata();
        } else {
            console.error('No recordId provided');
            this.showToast('Error', 'No recordId provided', 'error');
        }
    }

    updatedata() {
        console.log('Calling updateinvoiceStatus with recordId:', this.recordId);

        updateinvoiceStatus({ orderId: this.recordId })
            .then(() => {
                console.log('Success: Invoice status updated');
                this.showToast('Success', 'Invoice status updated successfully!', 'success');
                this.refreshPage();
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                console.error('Client-side error:', error);
                this.showToast('Error', this.errorMessage, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        console.log('Dispatching toast event:', evt);
        this.dispatchEvent(evt);
    }

    refreshPage() {
        console.log('Refreshing page');
        location.reload();
    }
}
