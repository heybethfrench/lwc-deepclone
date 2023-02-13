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
                System.debug('api name: ' + apiName);
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
        @AuraEnabled public String apiName {get; set;}

    }
    @AuraEnabled
    public static String cloneWithRelated(String sObjectType, String recordId, List<childRelationship> childObjects){
       
        System.debug('clone with related');
        System.debug('child relationships');
        System.debug(childObjects);

        String parentObjectFieldString = fetchsObjectFieldString(sObjectType);
        String childObjectString = '(SELECT Id FROM Contacts)';

        String queryString = 'SELECT ' + parentObjectFieldString /*+ childObjectString*/ + ' FROM ' + sObjectType + ' WHERE Id=\'' + recordId +'\'';
        
        

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

        String returnId = recordId;
        try {
            insert objToInsert;
            returnId = String.valueOf(objToInsert[0].Id);
        } catch (Exception e){
            System.debug(e);
            returnId = recordId;
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
    public static String fetchChildObjectQueryString(List<String> childObjects){
        String result = '';
        for(Integer i=0; i<childObjects.size();i++){
            String childObjectFields = fetchsObjectFieldString(childObjects[i]);
            result += ', ( SELECT' + childObjectFields +'FROM ' + childObjects[i] +')';  
            System.debug(result);          
        }
        return result;
    }
}