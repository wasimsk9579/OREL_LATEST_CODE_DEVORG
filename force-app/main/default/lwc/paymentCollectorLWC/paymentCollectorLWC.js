import { LightningElement,api } from 'lwc';
export default class PaymentCollectorLWC extends LightningElement {

    @api recordId;

    paymentOptions = [
        { label: 'Partial Payment', value: 'Partial Payment' },
        { label: 'Full Payment', value: 'Full Payment' },
    ];

}