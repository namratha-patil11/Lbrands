public class DGTL_HistoryTracking {
    
    @AuraEnabled
    public static DGTL_HistoryWrapper getHistoryRecords(Id objectId){
        DGTL_HistoryWrapper result = new DGTL_HistoryWrapper();
        system.debug('objectId---'+objectId);
        Map<Id,Placement_Content_Detail_History__c> Map_HistRec = new Map<Id,Placement_Content_Detail_History__c>();
        Map<Id,Placement_Content_History__c> Map_ContentHistRec = new Map<Id,Placement_Content_History__c>();
        Map<Id,list<String>> Map_ChangedFields = new Map<Id,list<String>>();
        list<String> list_ChangedFields = new list<String>();
        list<String> list_ChangedValue = new list<String>();
        
        String sObjName = objectId.getSObjectType().getDescribe().getName();
        result.objectName = sObjName;
        
        list<String> list_TrackingFields = new list<String>();
        
        String historyTrackingObj = '';
        
        if(sObjName == 'Placement_Content__c'){
            historyTrackingObj = 'Placement_Content_History__c';
        }else if(sObjName == 'Placement_Content_Detail__c'){
            historyTrackingObj = 'Placement_Content_Detail_History__c';
        }
        result.objectName = historyTrackingObj;
        
        list_TrackingFields = DGTL_DataAccessor.getHistoryTrackingFields(sObjName);
        
        string strsoql = 'SELECT Id,LastModifiedBy.Name,LastModifiedDate,';
        for(String eachField : list_TrackingFields){
            strsoql +=  eachField+',';
            strsoql += eachField.substringBefore('__c')+'_Change__c'+',';
        }
        strsoql = strsoql.removeEnd(',');
        strsoql += ' FROM '+historyTrackingObj+' WHERE '+sObjName+'=:objectId ';
        system.debug('strsoql---'+strsoql);
        
        // if Object ------ Placement_Content__c-------
        if(sObjName == 'Placement_Content__c'){
            List<Placement_Content_History__c> list_Records = new List<Placement_Content_History__c>();
            list_Records = Database.query(strsoql);
            system.debug('list_Records--'+list_Records);
            
            for(Placement_Content_History__c histRec : list_Records){
                system.debug('histRec---'+histRec);
                Map_ContentHistRec.put(histRec.Id, histRec);
            }
            system.debug('Map_ContentHistRec---'+Map_ContentHistRec);
            
            list<DGTL_HistWrapper> list_HistoryRecords = new list<DGTL_HistWrapper>();
            Map<Id,Placement_Content_History__c> Map_ChangedRecords = New  Map<Id,Placement_Content_History__c>();
            
            for(Id recordId : Map_ContentHistRec.keySet()){
                Map_ChangedRecords.put(recordId,Map_ContentHistRec.get(recordId));
                DGTL_HistWrapper wrapItem = New DGTL_HistWrapper();
                system.debug('recordId--'+recordId);
                String fieldLabel = '';
                String fieldValue = '';
                for(String eachField : list_TrackingFields){
                    String eachChangeField = eachField.substringBefore('__c')+'_Change__c';
                    if( Map_ContentHistRec.get(recordId).get(eachChangeField) == true){
                        fieldLabel += eachField.substringBefore('__c').replaceAll('_', ' ')+' , ';
                        fieldValue += eachField+',';
                    }
                }
                fieldValue = fieldValue.removeEnd(',');
                list_ChangedValue.add(fieldValue);
                list_ChangedFields.add(fieldLabel);
                Map_ChangedFields.put(recordId, list_ChangedFields);
                fieldLabel = fieldLabel.removeEnd(' , ');
                
                Placement_Content_History__c rec= new Placement_Content_History__c();
                rec = Map_ContentHistRec.get(recordId);
                
                wrapItem.changedBy = rec.LastModifiedBy.Name;
                wrapItem.changedDate = String.valueOf(rec.LastModifiedDate); 
                wrapItem.HistRecordId = recordId;
                wrapItem.List_ContentHistRec = Map_ContentHistRec.get(recordId);
                wrapItem.changedFields = fieldLabel;
                list_HistoryRecords.add(wrapItem);
            }
            
            result.list_ChangedValue = list_ChangedValue;
            result.Map_ChangedContentRecords = Map_ChangedRecords;
            result.contHistList = list_Records;
            result.Map_ChangedFields = Map_ChangedFields;
            result.list_ChangedFields = list_ChangedFields;
            result.list_HistoryRecords = list_HistoryRecords;
            
            
        }else if(sObjName == 'Placement_Content_Detail__c'){
            List<Placement_Content_Detail_History__c> list_Records = new List<Placement_Content_Detail_History__c>();
            list_Records = Database.query(strsoql);
            system.debug('list_Records--'+list_Records);
            
            for(Placement_Content_Detail_History__c histRec : list_Records){
                system.debug('histRec---'+histRec);
                Map_HistRec.put(histRec.Id, histRec);
            }
            system.debug('Map_HistRec---'+Map_HistRec);
            
            list<DGTL_HistWrapper> list_HistoryRecords = new list<DGTL_HistWrapper>();
            Map<Id,Placement_Content_Detail_History__c> Map_ChangedRecords = New  Map<Id,Placement_Content_Detail_History__c>();
            
            for(Id recordId : Map_HistRec.keySet()){
                Map_ChangedRecords.put(recordId,Map_HistRec.get(recordId));
                DGTL_HistWrapper wrapItem = New DGTL_HistWrapper();
                system.debug('recordId--'+recordId);
                String fieldLabel = '';
                String fieldValue = '';
                for(String eachField : list_TrackingFields){
                    String eachChangeField = eachField.substringBefore('__c')+'_Change__c';
                    if( Map_HistRec.get(recordId).get(eachChangeField) == true){
                        system.debug('eachField-------'+eachField);
                        if(eachField =='Link_Text__c') {
                            fieldLabel += 'URL';
                        }
                        else {
                            fieldLabel += eachField.substringBefore('__c').replaceAll('_', ' ')+' , ';
                        }
                        fieldValue += eachField+',';
                    }
                }
                fieldValue = fieldValue.removeEnd(',');
                list_ChangedValue.add(fieldValue);
                list_ChangedFields.add(fieldLabel);
                Map_ChangedFields.put(recordId, list_ChangedFields);
                fieldLabel = fieldLabel.removeEnd(' , ');
                
                Placement_Content_Detail_History__c rec= new Placement_Content_Detail_History__c();
                rec = Map_HistRec.get(recordId);
                
                wrapItem.changedBy = rec.LastModifiedBy.Name;
                wrapItem.changedDate = String.valueOf(rec.LastModifiedDate); 
                wrapItem.HistRecordId = recordId;
                wrapItem.contDetailHist = Map_HistRec.get(recordId);
                wrapItem.changedFields = fieldLabel;
                list_HistoryRecords.add(wrapItem);
            }
            
            result.list_ChangedValue = list_ChangedValue;
            result.Map_ChangedRecords = Map_ChangedRecords;
            result.contDetailHistList = list_Records;
            result.Map_ChangedFields = Map_ChangedFields;
            result.list_ChangedFields = list_ChangedFields;
            result.list_HistoryRecords = list_HistoryRecords;
        }
        
        return result;
    }
    
 /*   @AuraEnabled
    public static Placement_Content_Detail__c replaceValues(Id parentId, Placement_Content_Detail_History__c SourceRec , List<String> valuesToReplace){
        system.debug('parentId...'+parentId);
        Placement_Content_Detail__c replacedRecord;
        Map <Id,Placement_Content_Detail_History__c> sourceMap = New Map <Id,Placement_Content_Detail_History__c>();
        Map <Id,Placement_Content_Detail__c> newMap = New Map <Id,Placement_Content_Detail__c>();
        
        sourceMap.put(SourceRec.Id,SourceRec);
        
        String Fields ='';
        for(String eachField : valuesToReplace){
            Fields +=eachField+',';
        }
        Fields = Fields.removeEnd(',');
        String queryString = 'Select '+Fields+' FROM Placement_Content_Detail__c WHERE Id =:parentId LIMIT 1';
        system.debug('queryString...'+queryString);
        
        list<Placement_Content_Detail__c> contList = Database.query(queryString);
        
        for( Placement_Content_Detail__c contentDetail :contList ){
            replacedRecord = New Placement_Content_Detail__c();
            replacedRecord = contentDetail;
            newMap.put(contentDetail.Id,contentDetail);
        }
        system.debug('replacedRecord...before value assign...'+replacedRecord);
        for(String fieldApi : valuesToReplace){
            system.debug('fieldApi...'+fieldApi);
            system.debug('...sourceMap.get(SourceRec.Id).get(fieldApi)...'+sourceMap.get(SourceRec.Id).get(fieldApi));
            replacedRecord.put(fieldApi,sourceMap.get(SourceRec.Id).get(fieldApi)); 
        }
        system.debug('replacedRecord....'+replacedRecord);
        return replacedRecord;
    } */
    
    public class DGTL_HistoryWrapper{
        @AuraEnabled public String errorStatus{get;set;}
        @AuraEnabled public Boolean hasContents {get;set;}
        @AuraEnabled public String objectName {get;set;}
        @AuraEnabled public list<Placement_Content_History__c> contHistList {get;set;}
        @AuraEnabled public list<Placement_Content_Detail_History__c> contDetailHistList {get;set;}
        @AuraEnabled public Map<Id,list<String>> Map_ChangedFields {get;set;}
        @AuraEnabled public Map<Id,Placement_Content_Detail_History__c> Map_ChangedRecords {get;set;}
        @AuraEnabled public Map<Id,Placement_Content_History__c> Map_ChangedContentRecords {get;set;}
        @AuraEnabled public list<String> list_ChangedFields {get;set;}
        @AuraEnabled public list<String> list_ChangedValue {get;set;}
        @AuraEnabled public list<DGTL_HistWrapper> list_HistoryRecords {get;set;}
        
        public DGTL_HistoryWrapper()
        {
            errorStatus = '';
            hasContents = false;
            objectName = '';
            contHistList = New list<Placement_Content_History__c>();
            contDetailHistList = New list<Placement_Content_Detail_History__c>();
            Map_ChangedRecords = New Map<Id,Placement_Content_Detail_History__c>();
            Map_ChangedContentRecords = New Map<Id,Placement_Content_History__c>();
            Map_ChangedFields = New Map<Id,list<String>>();
            list_ChangedFields = New list<String>();
            list_ChangedValue = New list<String>();
            list_HistoryRecords = New list<DGTL_HistWrapper>();
        }
        
    }
    
    public class DGTL_HistWrapper{
        
        @AuraEnabled public Placement_Content_History__c contHist {get;set;}
        @AuraEnabled public Placement_Content_Detail_History__c contDetailHist {get;set;}
        @AuraEnabled public Placement_Content_History__c List_ContentHistRec {get;set;}
        @AuraEnabled public Map<Id,list<String>> Map_ChangedFields {get;set;}
        @AuraEnabled public list<String> list_ChangedFields {get;set;}
        @AuraEnabled public String changedBy {get;set;}
        @AuraEnabled public String changedDate {get;set;}
        @AuraEnabled public Id HistRecordId {get;set;}
        @AuraEnabled public String changedFields{get;set;}
        
        public DGTL_HistWrapper()
        {
            changedBy = '';
            changedDate ='';
            changedFields ='';
            contHist = New Placement_Content_History__c();
            contDetailHist = New Placement_Content_Detail_History__c();
            List_ContentHistRec = New Placement_Content_History__c();
            Map_ChangedFields = New Map<Id,list<String>>();
            list_ChangedFields = New list<String>();
        }
        
    }
    
    
}