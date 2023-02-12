public with sharing class SObjectMetadataMethods {
    @AuraEnabled(cacheable = true)
    public static List<childRelationship> getChildRelationships(){
        System.debug('getting the child relationships');
        Set<childRelationship> childSObjectTypes = new Set<childRelationship>();
        Map<String, String> label2value = new Map<String, String>();
        List<childRelationship> result = new List<childRelationship>();
        sObject dynamicObj = (SObject)Type.forName('Account').newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        for(Schema.ChildRelationship rels :sObjDescribe.getChildRelationships()){
            String label = String.valueOf(rels.getChildSObject().getDescribe().getLabelPlural());
            String devName = String.valueOf(rels.getRelationshipName());
   
            label2value.put(label, devName);
        }

        for(String label: label2value.keySet()){
            childRelationship child = new childRelationship();
            child.label = label;
            child.value = label2value.get(label);
    
            result.add(child);
        }
        

        return result;
    }

    public class childRelationship {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}

    }
    @AuraEnabled
    public static String cloneWithRelated(String recordId, List<String> childObjects){
       
        System.debug('clone with related');

        String childObjectString = '';

        for(Integer i=0; i<childObjects.size();i++){
            childObjectString = childObjectString + ', ( SELECT Id FROM ' + childObjects[i] +')';            
        }

        String queryString = 'SELECT Id, Name' + childObjectString + ' FROM Account WHERE Id=\'' + recordId +'\'';
        
        List<sObject> result = Database.query(queryString);

        //String sobjectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        //System.debug(sobjectType);
        
        System.debug('child object string: '+ childObjectString);
        System.debug('query string: ' + queryString);
        System.debug('query result: ' + result);

        List<SObject> objToInsert = new List<SObject>();

        for(sObject obj : result){
            SObject newObj = obj.clone(false, true, false, false);
            objToInsert.add(newObj);
        }

        insert objToInsert;
        
        return String.valueOf(objToInsert[0].Id);
    }
}