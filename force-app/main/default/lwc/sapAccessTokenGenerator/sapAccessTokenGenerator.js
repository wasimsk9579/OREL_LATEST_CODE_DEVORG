/*
* Component Name: sapAccessTokenGenerayor
* Author: Pooja V
* Date: 14-11-2023
* Description: This Lightning web component is designed to generate a SAP access token by calling the generateSapToken Apex method. 
  The access token is stored in the accessToken property. If the operation is successful, the component dispatches a CloseActionScreenEvent to close the screen. If there is an error, the error message is stored in the error property. 
  The component is designed to automatically trigger the generation of the SAP access token when it is loaded.
*/


import { LightningElement, track,api } from 'lwc';
import generateSapToken from '@salesforce/apex/sapConnectivityController.generateSapToken';
import updateDistributor from '@salesforce/apex/orlDistributorRecordController.updateDistributor'

import { CloseActionScreenEvent } from 'lightning/actions';

 
export default class SapAccessTokenGenerator extends LightningElement {
    @track accessToken; // A tracked property used to store the SAP access token retrieved from the Apex method.
    @track error;  // A tracked property used to store any error message encountered during the execution of the Apex method.
    @track distributorData;
    @api
    
    connectedCallback() {
       this.generateSapToken();
    }

    generateSapToken() {
        console.log('Generating SAP Token...');
        generateSapToken()
            .then(result => {
                
                console.log('credit result ---->',result);
            //    getBasicAuthCallout({ accessToken: this.accessToken }).then((res)=>{
            //     console.log('basic auth callout--->',res)
            //    }).catch((err)=>{
            //     console.log(err)
            //    })
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.error = error.body.message;
                console.error('Error:', this.error);
            });
    }

}