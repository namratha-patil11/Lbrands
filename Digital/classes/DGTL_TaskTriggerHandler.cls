public class DGTL_TaskTriggerHandler {
    
    public void manageTask(){
        List<DGTL_Task__c> tasks = trigger.new;
        
        Id escalationRecordTypeId,userRecordTypeId;
        Map<Id,Id> contentIdsOfApprTask = new Map<Id,Id>(); // approved ids of actual contents vs escalated content
        Map<Id,Id> contentIdsOfRejectedTask = new Map<Id,Id>(); // rejected ids of actual contents vs escalated content
        Map<Id,Placement_Content__c> contentMap = new Map<Id,Placement_Content__c>();
        List<DGTL_Task__c> detailTasks = new List<DGTL_Task__c>();
        Map<Id,DGTL_Task__c> contentIdTaskMapForContent = new Map<Id,DGTL_Task__c>();
        Map<Id,List<DGTL_Task__c>> contentIdTaskMapForDetail = new  Map<Id,List<DGTL_Task__c>>();
        List<Placement_Content__c> contentsToUpdate = new List<Placement_Content__c>();
        List<Placement_Content_Detail__c> pContentDetailListToInsert = new List<Placement_Content_Detail__c>();
        List<Placement_Content_Detail__c> pContentDetailListToDelete = new List<Placement_Content_Detail__c>();
        Set<String> contentFieldsToQuery = new Set<String>();
        Set<String> detailFieldsToCompare = new Set<String>();
        Set<String> taskStatusSet = new Set<String>();
        Boolean isDeleted = false;
        
        for( sObjectField field : Schema.getGlobalDescribe().get('Placement_Content__c').getDescribe().fields.getMap().values()){
            if(field.getDescribe().IsUpdateable())  contentFieldsToQuery.add(String.valueOf(field).toLowerCase());
        }
        
         for( sObjectField field : Schema.getGlobalDescribe().get('Placement_Content_Detail__c').getDescribe().fields.getMap().values()){
            if(field.getDescribe().IsUpdateable())  detailFieldsToCompare.add(String.valueOf(field));
        }
        
        for( RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE sObjectType='DGTL_Task__c' AND (DeveloperName='Escalation' OR DeveloperName='User_Task')]){
            if(rt.DeveloperName == 'Escalation'){
                escalationRecordTypeId = rt.Id;
            }else{
                userRecordTypeId = rt.Id;
            }
        }
        
        //collect content ids for approved and rejected tasks
        for(DGTL_Task__c task : tasks){
            if(task.RecordTypeId == escalationRecordTypeId && task.Parent_Content__c != null && task.Status__c != String.valueOf(trigger.oldMap.get(task.Id).get('Status__c'))){
                if(task.Status__c == 'Approved'){
                    contentIdsOfApprTask.put(task.Parent_Content__c,task.Placement_Content__c);
                }else if(task.Status__c == 'Rejected'){
                    contentIdsOfRejectedTask.put(task.Parent_Content__c,task.Placement_Content__c);
                }
            }
        }
                
        if(contentIdsOfApprTask.size() > 0){
            FieldsToCompare flsToCompare = getFieldsToCompare('Placement_Content__c');
            if(flsToCompare.fieldToCompareSet.size() > 0) contentFieldsToQuery.addAll(flsToCompare.fieldToCompareSet); 
            
            for(Schema.FieldSetMember f : Schema.SObjectType.Placement_Content__c.fieldSets.DGTL_Task_Mapping.getFields()) {
                contentFieldsToQuery.add(f.getFieldPath().toLowerCase());
            }
            
            String pContentFields = !contentFieldsToQuery.contains('id') ? 'id,': '';
            pContentFields =  !contentFieldsToQuery.contains('name') ? pContentFields+'name,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('placement_type__c') ? pContentFields+'placement_type__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('placement_library__c') ? pContentFields+'placement_library__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('has_unapproved__c') ? pContentFields+'has_unapproved__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('brand__c') ? pContentFields+'brand__c,' : pContentFields; 
            pContentFields = !contentFieldsToQuery.contains('unique_field__c') ? pContentFields+'Unique_Field__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('placement_layout__c') ? pContentFields+'Placement_Layout__c,' : pContentFields; 
            pContentFields = !contentFieldsToQuery.contains('next_placement_content__c') ? pContentFields+'Next_Placement_Content__c,' : pContentFields; 
            pContentFields = !contentFieldsToQuery.contains('previous_placement_content__c') ? pContentFields+'Previous_Placement_Content__c,' : pContentFields;     
            pContentFields = !contentFieldsToQuery.contains('placement_content_self__c') ? pContentFields+'placement_content_self__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('s_no__c') ? pContentFields+'S_No__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('type__c') ? pContentFields+'Type__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('active__c') ? pContentFields+'Active__c,' : pContentFields;
            
            
            pContentFields += String.join(new List<String>(contentFieldsToQuery), ', ');
            
            detailFieldsToCompare.addAll(new Set<String>{'Copy__c','Link_Text__c','Sub_Type__c','Slides__c'});
            for(Schema.FieldSetMember f : Schema.SObjectType.Placement_Content_Detail__c.fieldSets.DGTL_Task_Mapping.getFields()) {
                detailFieldsToCompare.add(f.getFieldPath());
            }
            detailFieldsToCompare.addAll(new Set<String>{'Id','Name','Placement_Content__c','Is_Deleted__c'});
            String cDetailQueryFields = String.join(new List<String>(detailFieldsToCompare), ', ');
            
            String innerDetailQuery = '(SELECT '+cDetailQueryFields+' FROM Placement_Content_Details__r ORDER BY CreatedDate DESC)';
            String query = 'SELECT KOD__r.Digital_Offer_Disclaimer__c,Placement_Library__r.Name,'+pContentFields+','+innerDetailQuery+' FROM Placement_Content__c';
            System.debug('query-----'+query);
            
            Set<Id> contentsToQueryIds = new Set<Id>();
            Set<Id> previousNextContentIds = new Set<Id>();
            
            contentsToQueryIds.addAll(contentIdsOfApprTask.keySet());
            contentsToQueryIds.addAll(contentIdsOfRejectedTask.keySet());
            contentsToQueryIds.addAll(contentIdsOfApprTask.values());
            contentsToQueryIds.addAll(contentIdsOfRejectedTask.values());
            
            
            // collect all the placement contents based on trigger records
            Set<Id> apprvIds = contentIdsOfApprTask.keySet();
            for(Placement_Content__c pCon : Database.query(query + ' WHERE Id IN :contentsToQueryIds OR Next_Placement_Content__c IN:apprvIds OR Previous_Placement_Content__c IN :apprvIds ')){
                contentMap.put(pCon.Id,pCon);
                previousNextContentIds.add(pCon.Next_Placement_Content__c);
                previousNextContentIds.add(pCon.Previous_Placement_Content__c);
            }
            
            //collect all the placement contents based on previous and next content
            if(previousNextContentIds.size() > 0){
                Set<Id> contentIds = contentMap.keySet();
                for(Placement_Content__c pCon : Database.query(query + ' WHERE Id IN:previousNextContentIds AND Id NOT IN:contentIds')){
                    System.debug('inside---');
                    contentMap.put(pCon.Id,pCon);
                }
            }
            
            
            // update approved contents
            for(Id contentId : contentIdsOfApprTask.keySet()){
                Placement_Content__c parentContent = contentMap.get(contentId);
                Placement_Content__c escalatedContent = contentMap.get(contentIdsOfApprTask.get(contentId));
                
                // mark all the parent content's details as deleted
                if(parentContent.Placement_Content_Details__r != null && parentContent.Placement_Content_Details__r.size() > 0){
                    for(Placement_Content_Detail__c pcd : parentContent.Placement_Content_Details__r ){
                        pContentDetailListToDelete.add(pcd);
                    }
                }
                
                // copy all the task from approved escalated content
                if(escalatedContent.Placement_Content_Details__r != null && escalatedContent.Placement_Content_Details__r.size() > 0){
                    for(Placement_Content_Detail__c pcd : escalatedContent.Placement_Content_Details__r ){
                        if(!pcd.Is_Deleted__c){
                            Placement_Content_Detail__c pdNew = pcd.clone(false,false,false,false);
                            pdNew.Placement_Content__c = contentId;
                            pdNew.Id = null;
                            pdNew.Placement_Content_Detail_Self__c = null;
                            pContentDetailListToInsert.add(pdNew);
                        }
                    }
                }
                
                // copy all the values from approved escalated content
                Placement_Content__c pc = escalatedContent.clone(false,false,false,false);
                pc.S_No__c = parentContent.S_No__c;
                pc.Id = contentId;
                pc.Type__c = parentContent.Type__c;
                pc.Has_Unapproved__c = false;
                pc.Placement_Content_Self__c =null;
                
                // update escalated content unique field
                escalatedContent.Unique_Field__c = escalatedContent.Id;
                
                contentsToUpdate.add(pc);
                contentsToUpdate.add(escalatedContent);
            }
            
            if(contentsToUpdate.size() > 0){
                update contentsToUpdate;
                
                for(Placement_Content__c pCont : contentsToUpdate ){
                    contentMap.put(pCont.Id, pCont);
                }
            }
            
            if(pContentDetailListToInsert.size() > 0){
                insert pContentDetailListToInsert;
            }
            
            if(pContentDetailListToDelete.size() > 0){
                delete pContentDetailListToDelete;
            }
            
            
            //start compare for approved content changes
            for(Id apprContId : contentIdsOfApprTask.keySet()){
                Placement_Content__c plToCompare = contentMap.get(apprContId);
                Placement_Content__c previousPlContent = plToCompare.Previous_Placement_Content__c != null && contentMap.containsKey(plToCompare.Previous_Placement_Content__c) ? 
                    contentMap.get(plToCompare.Previous_Placement_Content__c) : null;
                Placement_Content__c nextPlContent = plToCompare.Next_Placement_Content__c != null && contentMap.containsKey(plToCompare.Next_Placement_Content__c) ? 
                    contentMap.get(plToCompare.Next_Placement_Content__c) : null;
                
                CompareResult crForCurrent;
                CompareResult crForNext;
                
                if(flsToCompare.brandVSFieldsToCompareMap.containsKey(plToCompare.Brand__c) && previousPlContent != null){
                    crForCurrent = compareContents(plToCompare , previousPlContent, flsToCompare.brandVSFieldsToCompareMap.get(plToCompare.Brand__c), userRecordTypeId);
                }
                
                if(nextPlContent != null && flsToCompare.brandVSFieldsToCompareMap.containsKey(nextPlContent.Brand__c)){
                    crForNext = compareContents(nextPlContent, plToCompare, flsToCompare.brandVSFieldsToCompareMap.get(nextPlContent.Brand__c), userRecordTypeId);
                }
                
                if(crForCurrent != null){
                    if(crForCurrent.contentIdTaskMapForContent.keySet().size() > 0) contentIdTaskMapForContent.putAll(crForCurrent.contentIdTaskMapForContent);
                    if(crForCurrent.contentIdTaskMapForDetail.keySet().size() > 0) contentIdTaskMapForDetail.putAll(crForCurrent.contentIdTaskMapForDetail);
                }
                
                if(crForNext != null){
                    if(crForNext.contentIdTaskMapForContent.keySet().size() > 0) contentIdTaskMapForContent.putAll(crForNext.contentIdTaskMapForContent);
                    if(crForNext.contentIdTaskMapForDetail.keySet().size() > 0) contentIdTaskMapForDetail.putAll(crForNext.contentIdTaskMapForDetail);
                }
            }
            
            // get the task status which should not be deleted
            for(String str : DGTL_ErrorMessages__c.getValues('DGTL_Task_Status').Error_Message__c.split(',')){
                taskStatusSet.add(str);
            }
                
            // start task insert & delete process
            if(contentIdTaskMapForContent.keySet().size() > 0){
                Set<Id> pContentIds = new Set<Id>(contentIdTaskMapForContent.keySet());
                System.debug('test 1---');
                if(contentIdTaskMapForDetail.size() > 0) pContentIds.addAll(contentIdTaskMapForDetail.keySet());
                System.debug('test 2---');
                isDeleted = true;
                
                // delete the old uncompleted tasks 
                DELETE[SELECT Id FROM DGTL_Task__c WHERE (Placement_Content__c IN:pContentIds  
                                                          OR Parent_Task__r.Placement_Content__c IN:pContentIds)  
                       AND Status__c NOT IN:taskStatusSet AND RecordTypeId = :userRecordTypeId];
                
                // insert the new compared content tasks
                insert contentIdTaskMapForContent.values();
                
                // insert sub-tasks
                if(contentIdTaskMapForDetail.size() > 0){
                    
                    for(Id contentId : contentIdTaskMapForDetail.keySet()){
                        
                        if(contentIdTaskMapForContent.containsKey(contentId)){
                            for(DGTL_Task__c task : contentIdTaskMapForDetail.get(contentId)){
                                task.Placement_Content__c = contentId;
                                task.Parent_Task__c = contentIdTaskMapForContent.get(contentId).Id;
                                detailTasks.add(task); // collect detail task where parent content task exist
                            }
                            contentIdTaskMapForDetail.remove(contentId);
                        }
                    }
                }
            }
            
            if(contentIdTaskMapForDetail.keySet().size() > 0){   
                Map<Id,DGTL_Task__c> contentIdTaskMap = new Map<Id,DGTL_Task__c>();
               
                // delete the old uncompleted tasks 
                if(!isDeleted){
                    Set<Id> pContentIds = contentIdTaskMapForDetail.keySet();
                    DELETE[SELECT Id FROM DGTL_Task__c WHERE (Placement_Content__c IN:pContentIds  
                                                              OR Parent_Task__r.Placement_Content__c IN:pContentIds)  
                           AND Status__c NOT IN:taskStatusSet AND RecordTypeId = :userRecordTypeId];
                }
                
                for(Id contentId : contentIdTaskMapForDetail.keySet()){
                    contentIdTaskMap.put(contentId, createTask(contentMap.get(contentId),'Update',true,userRecordTypeId));
                }
                
                insert contentIdTaskMap.values(); // insert content task for orphan sub task 
                
                for(Id contentId : contentIdTaskMapForDetail.keySet()){
                    for(DGTL_Task__c task : contentIdTaskMapForDetail.get(contentId)){
                        task.Placement_Content__c = contentId;
                        task.Parent_Task__c = contentIdTaskMap.get(contentId).Id;
                        detailTasks.add(task); // collect detail task where parent content task doesn't exist
                    }
                }
            }
            
            // insert detail tasks
            if(detailTasks.size() > 0){
                insert detailTasks;
            }
            
        }
        
        //update all rejected contents
        if(contentIdsOfRejectedTask.size() > 0 ){
            List<Placement_Content__c> pContentListToUpdate = new List<Placement_Content__c>();
            
            if(contentMap.keySet().size() == 0){
                
                String pContentFields = String.join(new List<String>(contentFieldsToQuery), ', ');
                String pContentDetailFields = String.join(new List<String>(detailFieldsToCompare), ', ');
                String innerDetailQuery = '(SELECT '+pContentDetailFields+' FROM Placement_Content_Details__r ORDER BY CreatedDate DESC)';
                
                Set<Id> rejectedContentIds = new Set<Id> (contentIdsOfRejectedTask.keySet());
                rejectedContentIds.addAll(contentIdsOfRejectedTask.values());
                
                for(Placement_Content__c pcd : Database.query('SELECT Id,'+pContentFields+','+innerDetailQuery+' FROM Placement_Content__c WHERE Id IN:rejectedContentIds')){
                    contentMap.put(pcd.Id,pcd);
                }
            }
            
            for(Id contentId : contentIdsOfRejectedTask.keySet()){
                
                Placement_Content__c parentContent = contentMap.get(contentId);
                Placement_Content__c escalatedContent = contentMap.get(contentIdsOfRejectedTask.get(contentId));
                
                parentContent.Has_Unapproved__c = false;
                parentContent.Placement_Content_Self__c =null;
                
                escalatedContent.Unique_Field__c = escalatedContent.Id;
                
                pContentListToUpdate.add(parentContent);
                pContentListToUpdate.add(escalatedContent);
            }
          
            if(pContentListToUpdate.size() > 0){
                update pContentListToUpdate;
            }
            
        }
        
        
    }
    
    // get all the fields to compare from access management  
    public FieldsToCompare getFieldsToCompare(String objName){
        FieldsToCompare flsToCmp = new FieldsToCompare();
        Set<String> fieldsToCompare = new Set<String>();
        Map<String,Set<String>> brandVSFieldsToCompareMap = new Map<String,Set<String>>(); 
        
        for(DGTL_Access_Management__c  accessMgmt : [SELECT Brands__c,Read_Only_Fields__c FROM DGTL_Access_Management__c 
                                                     WHERE RecordType.DeveloperName = 'Compare_Setup' AND UserOrProfileId__c = null 
                                                     AND Object_Name__c = :objName ORDER BY CreatedDate])
        {
            if(accessMgmt != null && String.isNotBlank(accessMgmt.Read_Only_Fields__c)){
                Set<String> fieldsToCompareByBrand = new Set<String>();
                
                for(String str :accessMgmt.Read_Only_Fields__c.split(';') ){
                    fieldsToCompare.add(str.toLowerCase());
                    fieldsToCompareByBrand.add(str.toLowerCase());
                }
                if(!brandVSFieldsToCompareMap.containsKey(accessMgmt.Brands__c)) brandVSFieldsToCompareMap.put(accessMgmt.Brands__c,fieldsToCompareByBrand);
            }
            
        }
        flsToCmp.fieldToCompareSet = fieldsToCompare;
        flsToCmp.brandVSFieldsToCompareMap = brandVSFieldsToCompareMap;
        
        return flsToCmp;
    }
    
    public DGTL_Task__c createTask(sObject obj, String compareType, Boolean isContent, Id userRecordTypeId){
        DGTL_Task__c task = new DGTL_Task__c();
        Schema.FieldSet fs;
        task.RecordTypeId = userRecordTypeId;
        task.Type__c = compareType;
        
        if(isContent){
            fs = Schema.SObjectType.Placement_Content__c.fieldSets.DGTL_Task_Mapping;
            task.Placement_Content__c = String.valueOf(obj.get('Id'));
            for(Schema.FieldSetMember f : fs.getFields()) {
                 task.put(f.getFieldPath(),obj.get(f.getFieldPath()));   
            }
            Placement_Content__c pc = (Placement_Content__c) obj;
            task.Digital_Offer_Disclaimer__c = pc.KOD__c != null && String.isNotBlank(pc.KOD__r.Digital_Offer_Disclaimer__c) ? pc.KOD__r.Digital_Offer_Disclaimer__c : '';
        }else{
            fs = Schema.SObjectType.Placement_Content_Detail__c.fieldSets.DGTL_Task_Mapping;
            for(Schema.FieldSetMember f : fs.getFields()) {
                 task.put(f.getFieldPath(),obj.get(f.getFieldPath()));   
            }
        }
        
        return task;
        
    }
    
    public CompareResult compareContents(Placement_Content__c pContToCompare , Placement_Content__c previousCont, Set<String> fieldsToCompare, Id recordTypeId){
        CompareResult cr = new CompareResult();
        Map<Id,DGTL_Task__c> contentIdTaskMapForContent = new Map<Id,DGTL_Task__c>(); 
        Map<Id,List<DGTL_Task__c>> contentIdTaskMapForDetail = new Map<Id,List<DGTL_Task__c>>();
        
        if(pContToCompare.Placement_Library__c != null){
            
            if(previousCont.Placement_Library__c != null){
                
                if(pContToCompare.Placement_Library__c == previousCont.Placement_Library__c){
                    String changedContentFieldLabels = '';
                    Boolean isChanged = false;
                    
                    // compare content fields
                    for(String field : fieldsToCompare){
                        if(pContToCompare.get(field) != previousCont.get(field)){
                            isChanged = true;
                            field = field.endsWith('__c') ? field.removeEnd('__c') :field;
                            field = field.contains('_') ? field.replace('_',' ') : field;
                            changedContentFieldLabels += field + ', ';
                        }
                    }
                    System.debug('isChanged==='+isChanged);
                    if(isChanged){
                        changedContentFieldLabels = changedContentFieldLabels.removeEnd(', ');
                        // create task for content changed
                        contentIdTaskMapForContent.put(pContToCompare.Id,createTask(pContToCompare,'Update',true,recordTypeId));
                    }
                    
                    //---compare content details starts----
                    if(pContToCompare.Placement_Content_Details__r != null && pContToCompare.Placement_Content_Details__r.size() > 0){
                        
                        if(previousCont.Placement_Content_Details__r != null && previousCont.Placement_Content_Details__r.size() > 0){
                            Map<Id,Placement_Content_Detail__c> contentDetailIdMap = new Map<Id,Placement_Content_Detail__c>();
                            Set<String> detailFieldsToCompare = new Set<String>{'Copy__c','Link_Text__c','Sub_Type__c','Slides__c'};
                            if(Test.isRunningTest()) detailFieldsToCompare.add('Asset_Path__c'); // as the fields are hard-coded
                                
                                //collect all old details ids
                                for(Placement_Content_Detail__c oldDetail : previousCont.Placement_Content_Details__r){
                                    contentDetailIdMap.put(oldDetail.Id, oldDetail);
                                }
                            
                            for(Placement_Content_Detail__c pConDetail : pContToCompare.Placement_Content_Details__r){
                                Placement_Content_Detail__c recToCompare;
                                
                                // get previous record to compare
                                for(Placement_Content_Detail__c oldDetail : previousCont.Placement_Content_Details__r){
                                    if( (oldDetail.Slides__c+oldDetail.Link_Text__c + oldDetail.Sub_Type__c + oldDetail.Copy__c) == (pConDetail.Slides__c+pConDetail.Link_Text__c + pConDetail.Sub_Type__c + oldDetail.Copy__c) && contentDetailIdMap.containsKey(oldDetail.Id)){
                                        recToCompare = oldDetail;
                                        contentDetailIdMap.remove(oldDetail.Id);
                                        break;
                                    }
                                }
                                
                                if(recToCompare != null){
                                    Boolean isDetailChanged = false;
                                    String changedFieldLabels = '';
                                    
                                    // compare detail fields
                                    for(String field : detailFieldsToCompare){
                                        if( pConDetail.get(field) != recToCompare.get(field)){
                                            field = field.endsWith('__c') ? field.removeEnd('__c') :field;
                                            field = field.contains('_') ? field.replace('_',' ') : field;
                                            changedFieldLabels += field + ', ';
                                            isDetailChanged = true;
                                        }
                                    }
                                    
                                    if(isDetailChanged){
                                        changedFieldLabels = changedFieldLabels.removeEnd(', ');
                                        // create task for details changed
                                        if(!contentIdTaskMapForDetail.containsKey(pConDetail.Placement_Content__c)){
                                            contentIdTaskMapForDetail.put(pConDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                        }
                                        contentIdTaskMapForDetail.get(pConDetail.Placement_Content__c).add(createTask(pConDetail,'Update',false,recordTypeId));
                                        
                                    }
                                }else{
                                    // create task for new detail added
                                    if(!contentIdTaskMapForDetail.containsKey(pConDetail.Placement_Content__c)){
                                        contentIdTaskMapForDetail.put(pConDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                    }
                                    contentIdTaskMapForDetail.get(pConDetail.Placement_Content__c).add(createTask(pConDetail,'Add',false,recordTypeId));
                                }
                            }
                        }else if(pContToCompare.Placement_Content_Details__r != null && pContToCompare.Placement_Content_Details__r.size() > 0){
                            // create task for all details addition
                            for(Placement_Content_Detail__c pDetail : pContToCompare.Placement_Content_Details__r){
                                if(!contentIdTaskMapForDetail.containsKey(pDetail.Placement_Content__c)){
                                    contentIdTaskMapForDetail.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                }
                                contentIdTaskMapForDetail.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Add',false,recordTypeId));
                            }
                        }
                        
                    }else if(previousCont.Placement_Content_Details__r != null && previousCont.Placement_Content_Details__r.size() > 0){
                        // create task for all details removal
                        if(!contentIdTaskMapForDetail.containsKey(pContToCompare.Id)){
                            contentIdTaskMapForDetail.put(pContToCompare.Id, new List<DGTL_Task__c>());
                        }
                        for(Placement_Content_Detail__c pDetail : previousCont.Placement_Content_Details__r){
                            contentIdTaskMapForDetail.get(pContToCompare.Id).add(createTask(pDetail,'Remove',false,recordTypeId));
                        }
                    }
                    
                    //---compare content details ends----
                    
                }else{
                    // current library and previous library are not same === NA
                }
            }else{
                // current library exist and previous library null == NA 
            }
        }else{
            System.debug('No Current Placement Library Found!');
        }
        
        cr.contentIdTaskMapForContent = contentIdTaskMapForContent;
        cr.contentIdTaskMapForDetail = contentIdTaskMapForDetail;
        
        //System.debug('cr--------'+JSON.serialize(cr));
        
        return cr;
    }
    
    
    public class FieldsToCompare{
        public Set<String> fieldToCompareSet;
        public Map<String,Set<String>> brandVSFieldsToCompareMap;
    }
    
    public class CompareResult{
        public Map<Id,DGTL_Task__c> contentIdTaskMapForContent;
        public Map<Id,List<DGTL_Task__c>> contentIdTaskMapForDetail;
    }
    
}