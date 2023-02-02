import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';

export default class DeepClone extends LightningElement {
    @api objectApiName;
    @api recordId;

    @track childRelationships;
    @track error;

    @wire(getChildRelationships)
    getChildRelationships({error, data}) {
        if(data){
            this.childRelationships = data;
            console.log(JSON.stringify(data));
            this.error = undefined;
        } else if (error){
            this.error = error;
            this.childRelationships = undefined;
            console.log(JSON.stringify(error));
        }
    }
}