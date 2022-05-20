public class DGTL_Util {
    
   /* public static Map<String,List<sObject>> getConvertedData(Map<String,List<sObject>> dataMap){
        Map<String,Map<String,DGTL_Access_Management__c>> accessMngMap = new Map<String,Map<String,DGTL_Access_Management__c>>();
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        Map<String,List<sObject>> convertedDataMap = new Map<String,List<sObject>>();
        Map<String,List<String>> fieldsToIgnoreMap = getfieldsToIgnoreOnConversion();
        String digitalProfile = '';

        try{
            digitalProfile = [SELECT DGTL_Profile__c FROM User WHERE Id = :UserInfo.getUserId()].DGTL_Profile__c; // get current user digital profile
        }catch(QueryException qe){ System.debug('QueryException caught: '+qe.getMessage()); }
        
        for(DGTL_Access_Management__c accMang : [SELECT Brands__c,Object_Name__c,Writable_Fields__c FROM DGTL_Access_Management__c 
                                                 WHERE  RecordTypeId = :recordTypeId
                                                 AND (Object_Name__c IN :dataMap.keySet()) 
                                                 AND Writable_Fields__c != null 
                                                 AND (Team__c = :digitalProfile OR UserOrProfileId__c = :UserInfo.getUserId() 
                                                      OR UserOrProfileId__c = :UserInfo.getProfileId()) 
                                                 ORDER BY CreatedDate DESC  ])
        {
            if(!accessMngMap.containsKey(accMang.Brands__c)) accessMngMap.put(accMang.Brands__c, new Map<String,DGTL_Access_Management__c>());
            if(!accessMngMap.get(accMang.Brands__c).containsKey(accMang.Object_Name__c)) accessMngMap.get(accMang.Brands__c).put(accMang.Object_Name__c,accMang);
        }
        
        for(String objName : dataMap.keySet()){
            List<sObject> sObjList = new List<sObject>();
            SObjectType sobjMap = ((SObject)(Type.forName('Schema.'+objName).newInstance())).getSObjectType();
            DescribeSObjectResult fieldType = sobjMap.getDescribe();
            for(sObject sObj : dataMap.get(objName)){
                
                if(sObj.get('Id') != null){
                    String brand = String.valueOf(sObj.get('Brand__c')); // need to modify for generic api names
                    System.debug('brand----'+brand);
                    if(accessMngMap.containsKey(brand) && accessMngMap.get(brand).containsKey(objName)){
                        sObject convertedSObj = Id.valueOf(String.valueOf(sObj.get('Id'))).getSObjectType().newSObject();
                        convertedSObj.put('Id', sObj.get('Id'));
                        
                        // put the value of all the fields which needs to be ignored by access management permission
                        if(fieldsToIgnoreMap.containsKey(objName)){
                            for(String ignoreFld : fieldsToIgnoreMap.get(objName)){
                                string fielddatatype = string.valueof(fieldType.fields.getMap().get(ignoreFld).getDescribe().getType());
                                if(sObj.get(ignoreFld) == null &&  fielddatatype == 'BOOLEAN')
                                convertedSObj.put(ignoreFld, false);
                                else
                                convertedSObj.put(ignoreFld, sObj.get(ignoreFld));
                            }
                        }
                        
                        // put the value of all the writeable fields from access management
                        for(String str : accessMngMap.get(brand).get(objName).Writable_Fields__c.split(';')){
                            string fielddatatype = string.valueof(fieldType.fields.getMap().get(str).getDescribe().getType());
                            if(sObj.get(str) == null && fielddatatype == 'BOOLEAN')
                               convertedSObj.put(str, false);
                             else
                                convertedSObj.put(str, sObj.get(str));
                        }
                        
                        sObjList.add(convertedSObj); 
                    }else{                        
                       // throw new DGTL_Exception(sObj.get('Name') + ' - ' +DGTL_ErrorMessages__c.getValues('DGTL_Main_NoAccessMang').Error_Message__c);
                    }
                    
                }else{
                    sObjList.add(sObj); // new record doesn't need permission conversion
                }
            }
            convertedDataMap.put(objName,sObjList);
        }
        
        return convertedDataMap;
    }
    
    public static Map<String,List<String>> getfieldsToIgnoreOnConversion(){
        Map<String,List<String>> fieldsToIgnoreMap = new Map<String,List<String>>();
        Schema.FieldSet fs = Schema.SObjectType.Placement_Content__c.fieldSets.Fields_To_Ignore;
        Schema.FieldSet fs2 = Schema.SObjectType.Placement_Content_Detail__c.fieldSets.Fields_To_Ignore;
        
        for(Schema.FieldSetMember f : fs.getFields()) {
            if(!fieldsToIgnoreMap.containsKey('Placement_Content__c')) fieldsToIgnoreMap.put('Placement_Content__c', new List<String>());
            fieldsToIgnoreMap.get('Placement_Content__c').add(f.getFieldPath());   
        }
       
        for(Schema.FieldSetMember f2 : fs2.getFields()) {
            if(!fieldsToIgnoreMap.containsKey('Placement_Content_Detail__c')) fieldsToIgnoreMap.put('Placement_Content_Detail__c', new List<String>());
            fieldsToIgnoreMap.get('Placement_Content_Detail__c').add(f2.getFieldPath());   
        }
        
        return fieldsToIgnoreMap;
    }*/
    
    public static String getFloorsetName(String floorsetId){
        try{
            return [SELECT Name FROM DGTL_Floorset_Plan__c WHERE Id = :floorsetId].Name;
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
    }
    
    public static Map<String,String> getReadOnlyPickListFields(String objName){
        Map<String,String> fieldLabelMap = new Map<String,String>();
        Set<String> objFields = new Set<String>();
        
        for(String str : Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().keySet()){
            objFields.add(str.toLowerCase());
        }
        
        Schema.DescribeFieldResult fieldResult = DGTL_Access_Management__c.Read_Only_Fields__c.getDescribe();
        for(Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            String value = pickListVal.getValue();
            if(pickListVal.isActive() && objFields.contains(value.toLowerCase()))
                fieldLabelMap.put(value,pickListVal.getLabel());
        }

        return fieldLabelMap;
    }
    
    public static List<Schema.FieldSetMember> getFieldSetValues(String fieldSetName, String objectName){
        Schema.DescribeSObjectResult DescribeSObjectResultObj =  Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    } 

}