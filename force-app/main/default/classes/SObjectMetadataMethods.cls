public with sharing class SObjectMetadataMethods {
    @AuraEnabled(cacheable = true)
    public static List<childRelationship> getChildRelationships(String sObjectType){
        System.debug('getting the child relationships');

        Map<String, String> label2value = new Map<String, String>();
        Map<String, String> label2fieldname = new Map<String, String>();
        List<childRelationship> result = new List<childRelationship>();
        sObject dynamicObj = (SObject)Type.forName(sObjectType).newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        for(Schema.ChildRelationship rels :sObjDescribe.getChildRelationships()){
            String label = String.valueOf(rels.getChildSObject().getDescribe().getLabelPlural());
            String devName = String.valueOf(rels.getRelationshipName());
            String fieldName = String.valueOf(rels.getField());
            if(label != null && devName != null && fieldName != null){
                label2fieldname.put(label, fieldName);
                label2value.put(label, devName);
            }

        }

        for(String label: label2value.keySet()){
            childRelationship child = new childRelationship();
            child.label = label;
            child.value = label2value.get(label);
            child.fieldName = label2fieldname.get(label);
    
            result.add(child);
        }
        
        Integer valueCounter = 0;
        Integer nullvalueCounter = 0;

        for(childRelationship child : result){
            System.debug('label: ' + child.label);
            System.debug('value: ' + child.value);
            System.debug('field name: ' + child.fieldName);
            if(child.value == null || child.value == ''){
                nullvalueCounter += 1;
            } else {
                valueCounter+= 1;
            }
        }

        System.debug('records with a null value: ' + nullvalueCounter);
        System.debug('records with a value: ' + valueCounter);

        return result;
    }

    public class childRelationship {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String fieldName {get; set;}

    }
    @AuraEnabled
    public static String cloneWithRelated(String sObjectType, String recordId, List<String> childObjects){
       
        System.debug('clone with related');

        String parentObjectFieldString = '';
        String childObjectString = '';

        sObject dynamicObj = (SObject)Type.forName(sObjectType).newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        Map<String,Schema.SObjectField> mfields = sObjType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(mfields.keySet());
      
        for(Integer i = 0; i < fieldNames.size(); i++){
            if(i == 0){
                parentObjectFieldString += String.valueOf(mfields.get(fieldNames[i]).getDescribe().getName());  
            }else{
                parentObjectFieldString += ', ' + String.valueOf(mfields.get(fieldNames[i]).getDescribe().getName());
            }

        }

        for(Integer i=0; i<childObjects.size();i++){
            childObjectString = childObjectString + ', ( SELECT Id FROM ' + childObjects[i] +')';            
        }

        String queryString = 'SELECT ' + parentObjectFieldString + childObjectString + ' FROM ' + sObjectType + ' WHERE Id=\'' + recordId +'\'';
        
        

        //String sobjectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        //System.debug(sobjectType);
        System.debug('parent fields: ' + parentObjectFieldString);
        System.debug('child object string: '+ childObjectString);
        System.debug('query string: ' + queryString);


        List<sObject> result = Database.query(queryString);

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