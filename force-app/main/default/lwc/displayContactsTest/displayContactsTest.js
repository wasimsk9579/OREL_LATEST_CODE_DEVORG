import { LightningElement, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/getContactData.fetchContacts';

export default class DisplayContactsTest extends LightningElement {
    @track column =[
        {label: 'Name', fieldName: 'Name'},
        {label: 'Id' , fieldName: 'Id'}
    ];

    @track accountList;
    @wire (getContacts) wiredContacts({data, error}){
        if(data){
            this.accountList = data;
            console.log('data' +data);
        }
        else if( error) {
            console.log(error);
        }
    }
}