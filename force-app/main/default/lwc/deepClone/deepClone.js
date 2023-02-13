import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';
import cloneWithRelated from '@salesforce/apex/SObjectMetadataMethods.cloneWithRelated';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class DeepClone extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @api newRecordId;

    @track childRelationships;
    @track error;
    @track childRelationUiApi;
    
    selections = [];

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo({error, data}) {
        if(data){
            console.log('we changed how the sobject name is passed');
            this.childRelationUiApi = data;
            console.log('we got the object info and heres the api name');
            console.log(JSON.stringify(data.apiName));
            console.log('here are the childrelationships');
            console.log(JSON.stringify(data.childRelationships));
            console.log('heres the first relationship');
            console.log(JSON.stringify(data.childRelationships[0]));
            console.log('the relationships names');
            data.childRelationships.forEach(this.debugRelationships);
        }else if (error){
            console.log('there\'s an error in the lwc ui api wire method');
            console.log(error);
        }
    }


    @wire(getChildRelationships, { sObjectType : '$objectApiName'})
    getChildRelationships({error, data}) {
        if(data){
            this.childRelationships = data;
            //onsole.log(JSON.stringify(data));
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
        var clonedObjectRecordId = await cloneWithRelated({sObjectType: this.objectApiName, recordId: this.recordId, childObjects : this.selections });
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

    debugRelationships(item, index, arr){
        console.log(item.relationshipName);
        console.log(item.label);
    }
}