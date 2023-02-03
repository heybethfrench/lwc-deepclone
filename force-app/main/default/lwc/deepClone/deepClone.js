import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';
//import cloneWithRelated from '@salesforce/apex/SObjectMetadataMethods.cloneWithRelated';

export default class DeepClone extends LightningElement {
    @api objectApiName;
    @api recordId;

    @track childRelationships;
    @track error;
    
    selections = [];

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

    handleSelection(event){
        console.log('handled');
        this.selections = event.detail.value;
        console.log(event.detail.value);
        console.log(this.selections);
    }

    handleClone(){
        console.log('cloned');
        console.log(this.selections);
    }
}