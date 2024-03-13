// orelRequestTrackingTable.js
import { LightningElement, wire } from 'lwc';
import getOrelRequestsByUser from '@salesforce/apex/OrelRequestTrackingController.getOrelRequestsByUser';

export default class OrelRequestTrackingTable extends LightningElement {
    orelRequests = [];

    @wire(getOrelRequestsByUser)
    wiredOrelRequests({ error, data }) {
        if (data) {
            this.orelRequests = data;
        } else if (error) {
            console.error('Error fetching Orel Requests', error);
        }
    }

    columns = [
        { label: 'Name', fieldName: 'Name' },
        //{ label: 'Account', fieldName: 'Account__r.Name' },
        { label: 'Orel Reason', fieldName: 'Orel_Reason__c' },
        { label: 'Orel Status', fieldName: 'OrelStatus__c' },
        { label: 'Orel Initiated By', fieldName: 'Orel_Initiated_By__c' }
    ];
}