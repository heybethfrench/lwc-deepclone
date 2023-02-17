public with sharing class SObjectMetadataMethods {
    @AuraEnabled(cacheable = true)
    public static List<childRelationship> getChildRelationships(String sObjectType){
        System.debug('getting the child relationships');

        Map<String, String> label2value = new Map<String, String>();
        Map<String, String> label2fieldname = new Map<String, String>();
        Map<String, String> label2apiname = new Map<String, String>();
        List<childRelationship> result = new List<childRelationship>();
        sObject dynamicObj = (SObject)Type.forName(sObjectType).newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        for(Schema.ChildRelationship rels :sObjDescribe.getChildRelationships()){
            String label = String.valueOf(rels.getChildSObject().getDescribe().getLabelPlural());
            String devName = String.valueOf(rels.getRelationshipName());
            String fieldName = String.valueOf(rels.getField());
            String apiName = String.valueOf(rels.getChildSObject().getDescribe().getSObjectType());
            if(label != null && devName != null && fieldName != null){
                label2fieldname.put(label, fieldName);
                label2value.put(label, devName);
                label2apiname.put(label, apiName);
            }

        }

        for(String label: label2value.keySet()){
            childRelationship child = new childRelationship();
            child.label = label;
            child.value = label2value.get(label);
            child.fieldName = label2fieldname.get(label);
            child.apiName = label2apiname.get(label);
    
            result.add(child);
        }

        return result;
    }

    public class childRelationship {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String apiName {get; set;}

    }
    @AuraEnabled
    public static String cloneWithRelated(String sObjectType, String recordId, List<childRelationship> childObjects){

        //Schema.SObjectType sobjtype = Schema.getGlobalDescribe().get(sObjectType);
        Map<Id, String> childId2fieldName = new Map<Id, String>();
        Map<Id, SObject> childId2Record = new Map<Id, SObject>();
        Map<String, String> sobjectName2fieldname = new Map<String, String>();

        System.debug('clone with related');
        System.debug('child relationships');
        System.debug(childObjects);

        String parentObjectFieldString = fetchsObjectFieldString(sObjectType);
        String childObjectString = fetchChildObjectQueryString(childObjects, sObjectType);

        String queryString = 'SELECT ' + parentObjectFieldString + childObjectString + ' FROM ' + sObjectType + ' WHERE Id=\'' + recordId +'\'';

        List<sObject> result = Database.query(queryString);

        SObject parent = result[0].clone(false, true, false, false);
        insert parent;

        System.debug('query result: ' + result);
        List<SObject> objToInsert = new List<SObject>();


        List<SObject> childRecords = new List<SObject>();
        
        for(childRelationship child : childObjects){
            System.debug('child value: ' + child.value);
            System.debug('child field: ' + child.fieldName);
            System.debug(result[0].getSObjects(child.value));
            childRecords.addAll(result[0].getSObjects(child.value));
            sobjectName2fieldname.put(child.apiName, child.fieldName);
            
            
        }

        List<SObject> children2insert = new List<SObject>();

        for(SObject child : childRecords){
            
            String childSobjectType = child.Id.getSObjectType().getDescribe().getName();
            String parentFieldName = sobjectName2fieldname.get(childSobjectType);
            
            SObject childClone = child.clone(false, true, false, false);
            Id oldId = (Id)childClone.put(parentFieldName, parent.Id);
            System.debug(childClone.get(parentFieldName));
            children2insert.add(childClone);
        }

        System.debug('parent Id ' + parent.Id);
        String returnId = parent.Id;
        try {
            insert children2insert;
            
            returnId = parent.Id;
            System.debug('everything ran fine');
        } catch (Exception e){
            System.debug(e);
            String errorMsg = e.getMessage();
            System.debug(errorMsg);
            //throw new AuraHandledException(ErrorMsg);
            returnId = recordId;
        } finally {
            
        }
        
        
        return returnId;
    }

    public static String fetchsObjectFieldString(String sObjectType){
        System.debug('getting fields');
        String result = '';

        sObject dynamicObj = (SObject)Type.forName(sObjectType).newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        Map<String,Schema.SObjectField> mfields = sObjType.getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(mfields.keySet());
      
        for(Integer i = 0; i < fieldNames.size(); i++){
            if(i == 0){
                result += String.valueOf(mfields.get(fieldNames[i]).getDescribe().getName());  
            }else{
                result += ', ' + String.valueOf(mfields.get(fieldNames[i]).getDescribe().getName());
            }

        }
        return result;
    }

    //pass plural label plus api name, currently only passing plural label
    public static String fetchChildObjectQueryString(List<childRelationship> childObjects, String parentSObject){
        String result = '';
        for(Integer i=0; i<childObjects.size();i++){
            sObject dynamicObj = (SObject)Type.forName(childObjects[i].apiName).newInstance();

            System.debug(parentSObject + '_' + childObjects[i].apiName);

            SObjectType sObjType = dynamicObj.getSObjectType();
            DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

            Deep_Clone_Configuration__mdt dcConfig = Deep_Clone_Configuration__mdt.getInstance(parentSObject + '_' + childObjects[i].apiName);
            System.debug('deep clone configuration');
            System.debug(dcConfig);
            Schema.FieldSet fieldset = sObjDescribe.fieldSets.getMap().get(parentSObject);
            System.debug('field set');
            System.debug(fieldset);
            String childObjectFields = fetchsObjectFieldString(childObjects[i].apiName);

            if(i == 0){
                result += ', ( SELECT ' + childObjectFields +' FROM ' + childObjects[i].value +')'; 
            } else {
                result += ', ( SELECT ' + childObjectFields +' FROM ' + childObjects[i].value +')'; 
            }
             
            System.debug(result);          
        }
        return result;
    }
}