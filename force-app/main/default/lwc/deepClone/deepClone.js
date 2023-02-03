import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';
import cloneWithRelated from '@salesforce/apex/SObjectMetadataMethods.cloneWithRelated';
import { NavigationMixin } from 'lightning/navigation';

export default class DeepClone extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @api newRecordId;

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
    }

    async handleClone(){
        console.log('cloned');
        console.log(this.selections);
        var clonedObjectRecordId = await cloneWithRelated({recordId: this.recordId, childObjects : this.selections });
        console.log('it ran bro');
        console.log(clonedObjectRecordId);
        console.log('its navigate now');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: clonedObjectRecordId,
                actionName: 'view',
            },
        });
    }
}