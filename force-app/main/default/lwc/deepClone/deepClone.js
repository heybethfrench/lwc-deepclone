import { LightningElement, api, wire, track } from 'lwc';
import getChildRelationships from '@salesforce/apex/SObjectMetadataMethods.getChildRelationships';
import cloneWithRelated from '@salesforce/apex/SObjectMetadataMethods.cloneWithRelated';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class DeepClone extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;
    @api newRecordId;

    @track childRelationships;
    @track error;
    //@track childRelationUiApi;
    selectedChildRelationships = [];
    
    selections = [];

    /*@wire(getObjectInfo, { objectApiName: '$objectApiName' })
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
*/

    @wire(getChildRelationships, { sObjectType : '$objectApiName'})
    getChildRelationships({error, data}) {
        if(data){
            this.childRelationships = data;
            console.log(JSON.stringify(data));
            //data.forEach(this.debugRelationships);
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
        console.log('here are the selections');
        console.log(this.selections);

        for(let i=0; i< this.childRelationships.length; i++){
            if(this.selections.includes(this.childRelationships[i].value)){
                console.log(this.childRelationships[i].value);
                this.selectedChildRelationships.push(this.childRelationships[i]);
            }
        }
                
        console.log('heres the new list');
        console.log(JSON.stringify(this.selectedChildRelationships));
        console.log('now it passes selected relationships');
       
        var clonedObjectRecordId = await cloneWithRelated({sObjectType: this.objectApiName, recordId: this.recordId, childObjects : this.selectedChildRelationships });
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

    selectChildRelationships(item){
        if(this.selections.includes(item.value)){
            this.selectedChildRelationships.push(item);
        }
    }

}
