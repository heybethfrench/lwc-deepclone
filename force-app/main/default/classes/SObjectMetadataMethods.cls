public with sharing class SObjectMetadataMethods {
    @AuraEnabled(cacheable = true)
    public static List<childRelationship> getChildRelationships(){
        Set<childRelationship> childSObjectTypes = new Set<childRelationship>();
        Map<String, String> label2value = new Map<String, String>();
        List<childRelationship> result = new List<childRelationship>();
        sObject dynamicObj = (SObject)Type.forName('Account').newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        for(Schema.ChildRelationship rels :sObjDescribe.getChildRelationships()){
            String label = String.valueOf(rels.getChildSObject().getDescribe().getLabelPlural());
            String devName = String.valueOf(rels.getChildSObject());
   
            label2value.put(label, devName);
        }
        System.debug('from the map');
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
}