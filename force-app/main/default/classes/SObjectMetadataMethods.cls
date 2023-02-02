public with sharing class SObjectMetadataMethods {
    @AuraEnabled(cacheable = true)
    public static List<String> getChildRelationships(){
        Set<String> childSObjectTypes = new Set<String>();
        sObject dynamicObj = (SObject)Type.forName('Account').newInstance();
        SObjectType sObjType = dynamicObj.getSObjectType();
        DescribeSobjectResult sObjDescribe = sObjType.getDescribe();

        for(Schema.ChildRelationship rels :sObjDescribe.getChildRelationships()){
            childSObjectTypes.add(String.valueOf(rels.getChildSObject()));
            System.debug(rels.getChildSObject());
        }

        List<String> result = new List<String>();
        result.addAll(childSObjectTypes);

        return result;
    }
}