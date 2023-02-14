import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';
import cloneWithRelated from '@salesforce/apex/SObjectMetadataMethods.cloneWithRelated';
import { NavigationMixin } from 'lightning/navigation';
//import { showToastEvent } from 'lightning/platformShowToastEvent';

export default class DeepClone extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @api newRecordId;

    @track childRelationships;
    @track error;

    selectedChildRelationships = [];
    selections = [];

    @wire(getChildRelationships, { sObjectType : '$objectApiName'})
    getChildRelationships({error, data}) {
        if(data){
            this.childRelationships = data;
            this.error = undefined;
        } else if (error){
            this.error = error;
            this.childRelationships = undefined;
            console.log('error in getChildRelationships wire method');
            console.log(JSON.stringify(error));
        }
    }

    handleSelection(event){
        console.log('event handled');
        this.selections = event.detail.value;
        console.log(event.detail.value);
    }

    async handleClone(){
        console.log('cloned');
        console.log('here are the selections');
        
        for(let i=0; i< this.childRelationships.length; i++){
            if(this.selections.includes(this.childRelationships[i].value)){
                this.selectedChildRelationships.push(this.childRelationships[i]);
            }
        }
        
        
            var clonedObjectRecordId = await cloneWithRelated({sObjectType: this.objectApiName, recordId: this.recordId, childObjects : this.selectedChildRelationships });
            console.log('it ran bro');
            console.log(clonedObjectRecordId);
            console.log('its navigating now');
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: clonedObjectRecordId,
                    actionName: 'view',
                },
            });

    }

}
