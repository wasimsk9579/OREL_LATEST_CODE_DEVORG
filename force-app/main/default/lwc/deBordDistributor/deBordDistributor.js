import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import updateAccountFields from '@salesforce/apex/OrelDeboardingController.createOrelRequestRecord';

export default class DeBoardDistributor extends LightningElement {
    @api userId = USER_ID; 
    @track showModal = false;
    @track reason = '';

    @track isDeboardButtonDisabled = false;


    handleDeboard() {
        this.showModal = true;
        this.isDeboardButtonDisabled = true; // Disable the button when clicked
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleSubmit() {
        console.log('user id is', this.userId);
        console.log('resson is', this.reason);

        updateAccountFields({ userId: this.userId, reason: this.reason })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: 'Deboarding submitted successfully.',
                        variant: 'success',
                    })
                );
                this.showModal = false;
            })
            .catch(error => {
                console.error('Error updating Account: ', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message || 'Deboarding submission failed.',
                        variant: 'error',
                    })
                );
                this.showModal = false;
            });
    }

    handleCancel() {
        this.showModal = false;
    }
}