/**
*    @author Vipul Mittal  
*	 @date   17/08/2018
*    @description   schedulable batch class for Commerce Services tasks
**/


public class DGTL_TaskManagerScheduledBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    
    private String pType;
    private Set<String> fieldsToCompare;
    private String pContentInnerQuery;
    private Id taskRecordTypeId;
    private Map<String,String> comparedFromNameMap;
    private Map<Id,Map<String,Map<String,Map<String,String>>>> dayViewTaskDataMap;
    public String brand;
    public Map<String,Integer> typeScheduleIntervalMap;
    
    // constructor without parameter for schedule
    public DGTL_TaskManagerScheduledBatch(){}
    
    // constructor with parameter for batch
    public DGTL_TaskManagerScheduledBatch(String brand, Map<String,Integer> typeScheduleIntervalMap){
        this.brand = brand;
        this.typeScheduleIntervalMap = typeScheduleIntervalMap;
        for(String pType : typeScheduleIntervalMap.keySet()){
            this.pType = pType;
            break;
        }
        comparedFromNameMap = new Map<String,String>(); //FloorsetPlanId
        dayViewTaskDataMap = new Map<Id,Map<String,Map<String,Map<String,String>>>>();//FloorsetPlanId=>LayoutName=>DeviceType=>changeType(Add,update,remove)=> main message
    }
    
    public Database.querylocator start(Database.BatchableContext BC){ 
        Set<Id> fPlanIds = getFloorsetPlanIds(typeScheduleIntervalMap.get(pType) != 0 ? System.now().addHours(typeScheduleIntervalMap.get(pType)) : System.now());
        fieldsToCompare = getFieldsToCompare('Placement_Content__c');
        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.addAll(fieldsToCompare);
        
        if(fPlanIds != null && fPlanIds.size() > 0 && fieldsToCompare.size() > 0){
            for(Schema.FieldSetMember f : Schema.SObjectType.Placement_Content__c.fieldSets.DGTL_Task_Mapping.getFields()) {
               fieldsToQuery.add(f.getFieldPath().toLowerCase());
            }
            fieldsToQuery.addAll(new Set<String>{'id','type__c','name','placement_type__c','ab_test_name__c','placement_library__c','next_placement_content__c',
                'main_message__c','previous_placement_content__c','offer_type__c'});
            
           /* String pContentFields = !fieldsToCompare.contains('id') ? 'id,': '';
            pContentFields = !fieldsToQuery.contains('type__c') ? pContentFields+'Type__c,' : pContentFields;
            pContentFields =  !fieldsToQuery.contains('name') ? pContentFields+'Name,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('placement_type__c') ? pContentFields+'Placement_type__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('ab_test_name__c') ? pContentFields+'AB_Test_Name__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('placement_library__c') ? pContentFields+'Placement_Library__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('next_placement_content__c') ? pContentFields+'Next_Placement_Content__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('main_message__c') ? pContentFields+'Main_Message__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('previous_placement_content__c') ? pContentFields+'Previous_Placement_Content__c,' : pContentFields;
            pContentFields = !fieldsToQuery.contains('offer_type__c') ? pContentFields+'Offer_Type__c,' : pContentFields;*/
            
            String pContentFields = String.join(new List<String>(fieldsToQuery), ', '); 
            pContentInnerQuery = '(SELECT KOD__r.Digital_Offer_Disclaimer__c,Placement_Library__r.Name,'+pContentFields+' FROM Placement_Content__r WHERE Active__c = true AND (Type__c = \'Controlled\' OR Type__c = \'Takedown\' OR Type__c = \'AB Test\' OR Type__c = \'Contingency\') ORDER BY S_No__c)';
            
           // System.debug('queryyy====SELECT Id,Page_Types__c,Time_No__c,Device_Type__c,Date_Formula__c, '+pContentInnerQuery+' FROM Placement_Layout__c WHERE Floorset_Plan__c IN :fPlanIds AND Is_Deleted__c = false');
            
            return Database.getQueryLocator('SELECT Id,Name,Page_Types__c,Collection_Page_Name__c,Collection_Page_Url__c,Floorset_Plan__c,Brands__c,Time_No__c,Device_Type__c,Date_Formula__c, '+pContentInnerQuery+' FROM Placement_Layout__c WHERE Floorset_Plan__c IN :fPlanIds AND Compared_Placement_Layout__c = null AND Type__c = \'Layout\' AND Is_Deleted__c != true order by Floorset_Plan__c,Page_Types__c,Device_Type__c');
        }else{
            return Database.getQueryLocator('SELECT Id FROM Placement_Layout__c LIMIT 0');
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Placement_Layout__c> scope){
        Placement_Layout__c previousLayout;
        Set<String> detailFieldsToCompare;
        List<sObject> sObjListToUpdate;
        List<DGTL_Task__c> detailTasks = new List<DGTL_Task__c>();
        List<DGTL_Task__c> layoutTasks = new List<DGTL_Task__c>();
        Map<Id,DGTL_Task__c> contentIdTaskForContentMap = new Map<Id,DGTL_Task__c>();
        Map<Id,List<DGTL_Task__c>> contentIdTaskForDetailMap = new Map<Id,List<DGTL_Task__c>>();
        
        Map<String,Map<String,Map<String,String>>> layoutDayViewMap = new Map<String,Map<String,Map<String,String>>>();
        Map<String,Map<String,String>> deviceTypeDayViewMap = new Map<String,Map<String,String>>();
        Map<String,String> changeTypeDayViewMap = new Map<String,String>();
        
        Placement_Layout__c pLToCompare = scope[0]; // since batch size will always be one
        Date dateFormula =  pLToCompare.Date_Formula__c;
        String pageType = pLToCompare.Page_Types__c;
        String deviceType = pLToCompare.Device_Type__c;
        String brands = pLToCompare.Brands__c;
        String editorialName = pLToCompare.Collection_Page_Name__c != null ? pLToCompare.Collection_Page_Name__c : null;
         String editorialPageName = pLToCompare.Page_Types__c == 'Editorials' && String.isNotBlank(pLToCompare.Collection_Page_Name__c) 
                        ? ' - '+pLToCompare.Collection_Page_Name__c : '';
        System.debug('pLToCompare======'+pLToCompare);
        
        try{
            String query = 'SELECT Id,Name,Collection_Page_Name__c,Collection_Page_Url__c,Date_Formula__c,Time_No__c,'+pContentInnerQuery+' FROM Placement_Layout__c WHERE Date_Formula__c <= :dateFormula';
            query += ' AND Brands__c = :brands AND Is_Deleted__c = false AND Type__c = \'Layout\' AND Collection_Page_Name__c = :editorialName';
            query += ' AND Page_Types__c = :pageType AND Device_Type__c =:deviceType ORDER BY Date_Formula__c DESC,Time_No__c DESC LIMIT 10';
            
            // get the immediate previous layout to compare
            for(Placement_Layout__c pLay : Database.query(query)){
                if( (pLay.Date_Formula__c == pLToCompare.Date_Formula__c && pLay.Time_No__c < pLToCompare.Time_No__c) || pLay.Date_Formula__c < pLToCompare.Date_Formula__c){
                    previousLayout = pLay;
                    break;
                }
            } 
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
        
        System.debug('previousLayout======'+previousLayout);
        
        if(previousLayout != null){
            comparedFromNameMap.put(pLToCompare.Floorset_Plan__c + '-' + pLToCompare.Device_Type__c + '-' + pLToCompare.Page_Types__c+editorialPageName, previousLayout.Name+'~'+previousLayout.Id);
            sObjListToUpdate = new List<sObject>();
            pLToCompare.Compared_Placement_Layout__c = previousLayout.Id;
            previousLayout.Parent_Placement_Layout__c = pLToCompare.Id;
            
            sObjListToUpdate.add(pLToCompare);
            sObjListToUpdate.add(previousLayout);
            
            if(previousLayout != null && String.isNotBlank(previousLayout.Collection_Page_Url__c) && 
               String.isNotBlank(pLToCompare.Collection_Page_Url__c) && 
               pLToCompare.Collection_Page_Url__c != previousLayout.Collection_Page_Url__c)
            {
                if(taskRecordTypeId == null){
                    taskRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='DGTL_Task__c' AND DeveloperName='User_Task'].Id;
                }
                //create Task
                DGTL_Task__c task = new DGTL_Task__c(RecordTypeId=taskRecordTypeId,Editorial_Placement_Layout__c=pLToCompare.Id,Collection_Page_URL__c = pLToCompare.Collection_Page_URL__c);
                layoutTasks.add(task);
            }
            
            if(previousLayout.Placement_Content__r != null && previousLayout.Placement_Content__r.size() > 0){ 
                
                if(pLToCompare.Placement_Content__r != null && pLToCompare.Placement_Content__r.size() > 0){
                    System.debug('inside========');
                    Set<Id> pContentIds = new Set<Id>();
                    Map<Id,Placement_Content__c> previousContentIdMap = new Map<Id,Placement_Content__c>();
                    Map<String,List<Placement_Content__c>> pLibraryPreviousContentsMap = new Map<String,List<Placement_Content__c>>();
                    Map<Id,List<Placement_Content_Detail__c>> contentIdDetailsMap  = new Map<Id,List<Placement_Content_Detail__c>> ();
                    
                    for(Placement_Content__c pContentNew : pLToCompare.Placement_Content__r){
                        pContentIds.add(pContentNew.Id); // collect new content ids to query details
                    }
                    
                    // collect all old contents w.r.t. placement library
                    for(Placement_Content__c pContentOld : previousLayout.Placement_Content__r){
                        previousContentIdMap.put(pContentOld.Id,pContentOld); // collect old content ids to query details
                        if(pContentOld.Placement_Library__c != null){
                            String abTestName = String.isNotBlank(pContentOld.AB_Test_Name__c) ? pContentOld.AB_Test_Name__c : '';
                            if(!pLibraryPreviousContentsMap.containsKey(pContentOld.Placement_Library__c+'-'+pContentOld.Type__c+'-'+abTestName)) pLibraryPreviousContentsMap.put(pContentOld.Placement_Library__c+'-'+pContentOld.Type__c+'-'+abTestName,new List<Placement_Content__c>());
                            pLibraryPreviousContentsMap.get(pContentOld.Placement_Library__c+'-'+pContentOld.Type__c+'-'+abTestName).add(pContentOld);
                        } 
                    }
                    
                    if(previousContentIdMap.keySet().size() > 0) pContentIds.addAll(previousContentIdMap.keySet());
                    
                    // query content details
                    if(pContentIds.size() > 0){
                        detailFieldsToCompare = new Set<String>{'Copy__c','Link_Text__c','Sub_Type__c','Slides__c'};
                            if(Test.isRunningTest()) detailFieldsToCompare.add('Asset_Path__c'); // as the fields are hard-coded
                            Set<String> detFieldsToQuery = new Set<String>();
                        detFieldsToQuery.addAll(detailFieldsToCompare);
                        for(Schema.FieldSetMember f : Schema.SObjectType.Placement_Content_Detail__c.fieldSets.DGTL_Task_Mapping.getFields()) {
                            detFieldsToQuery.add(f.getFieldPath());
                        }
                        System.debug('detFieldsToQuery-----'+JSON.serialize(detFieldsToQuery));
                        String cDetailQueryFields = String.join(new List<String>(detFieldsToQuery), ', ');
                        
                        for(Placement_Content_Detail__c pcDetail : Database.query('SELECT Id,Name, Placement_Content__c,'+cDetailQueryFields+' FROM Placement_Content_Detail__c WHERE Placement_Content__c IN : pContentIds ORDER BY CreatedDate DESC '))
                        {
                            if(!contentIdDetailsMap.containsKey(pcDetail.Placement_Content__c)){
                                contentIdDetailsMap.put(pcDetail.Placement_Content__c,new List<Placement_Content_Detail__c>());                           
                            } 
                            contentIdDetailsMap.get(pcDetail.Placement_Content__c).add(pcDetail);
                        }
                    }
                    
                    // start compare
                    for(Placement_Content__c pCon : pLToCompare.Placement_Content__r){
                        String abTestName = String.isNotBlank(pCon.AB_Test_Name__c) ? pCon.AB_Test_Name__c : '';
                        if(pCon.Placement_Library__c != null ){
                            if(pLibraryPreviousContentsMap.containsKey(pCon.Placement_Library__c+'-'+pCon.Type__c+'-'+abTestName)){
                                System.debug('library detected====');
                                Placement_Content__c contentToCompareFrom;
                                
                                // get the old content to compare based on library
                                for(Placement_Content__c pCont : pLibraryPreviousContentsMap.get(pCon.Placement_Library__c+'-'+pCon.Type__c+'-'+abTestName)){
                                    if(previousContentIdMap.containsKey(pCont.Id)){
                                        contentToCompareFrom = pCont;
                                        pCon.Previous_Placement_Content__c = pCont.Id;
                                        pCont.Next_Placement_Content__c = pCon.Id; // update compared rec Id
                                        sObjListToUpdate.add(pCon); 
                                        sObjListToUpdate.add(pCont); 
                                        previousContentIdMap.remove(pCont.Id);
                                        break;
                                    }
                                }
                                System.debug('contentToCompareFrom-----'+contentToCompareFrom);
                                if(contentToCompareFrom != null){
                                    String changedContentFieldLabels = '';
                                    Boolean isChanged = false;
                                    
                                    // compare content fields
                                    for(String field : fieldsToCompare){
                                        if(pCon.get(field) != contentToCompareFrom.get(field)){
                                            isChanged = true;
                                            field = field.endsWith('__c') ? field.removeEnd('__c') :field;
                                            field = field.contains('_') ? field.replace('_',' ') : field;
                                            changedContentFieldLabels += field + ', ';
                                        }
                                    }
                                    
                                    if(isChanged){
                                        changedContentFieldLabels = changedContentFieldLabels.removeEnd(', ');
                                        String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                        changeTypeDayViewMap.put('Update',changeTypeDayViewMap.containsKey('Update') ? 
                                                                 changeTypeDayViewMap.get('Update')+'<br/><br/> <b>'+ offerType + '</b> - ' + pCon.Main_Message__c :  
                                                                 '<b>'+ offerType + '</b> - ' + pCon.Main_Message__c);
                                        // create task for content changed
                                        contentIdTaskForContentMap.put(pCon.Id,createTask(pCon,'Update',true));
                                    }
                                    
                                    //---compare content details starts----
                                    if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCon.Id)){
                                        
                                        if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(contentToCompareFrom.Id)){
                                            Integer recCount = 0;
                                            List<Placement_Content_Detail__c> oldPLDetailsList = contentIdDetailsMap.get(contentToCompareFrom.Id);
                                            Map<Id,Placement_Content_Detail__c> contentDetailIdMap = new Map<Id,Placement_Content_Detail__c>();
                                            
                                            //collect all old details ids
                                            for(Placement_Content_Detail__c oldDetail : oldPLDetailsList){
                                                contentDetailIdMap.put(oldDetail.Id, oldDetail);
                                            }
                                            
                                            for(Placement_Content_Detail__c pConDetail : contentIdDetailsMap.get(pCon.Id)){
                                                Placement_Content_Detail__c recToCompare;
                                                System.debug('inside details-----');
                                                // get previous record to compare
                                                for(Placement_Content_Detail__c oldDetail : oldPLDetailsList){
                                                    if( (oldDetail.Slides__c + oldDetail.Link_Text__c + oldDetail.Sub_Type__c + oldDetail.Copy__c) == (pConDetail.Slides__c + pConDetail.Link_Text__c + pConDetail.Sub_Type__c + oldDetail.Copy__c) && contentDetailIdMap.containsKey(oldDetail.Id)){
                                                        recToCompare = oldDetail;
                                                        contentDetailIdMap.remove(oldDetail.Id);
                                                        break;
                                                    }
                                                }
                                                System.debug('recToCompare-----'+recToCompare);
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
                                                        if(!contentIdTaskForDetailMap.containsKey(pConDetail.Placement_Content__c)){
                                                            contentIdTaskForDetailMap.put(pConDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                                        }
                                                        contentIdTaskForDetailMap.get(pConDetail.Placement_Content__c).add(createTask(pConDetail,'Update',false));
                                                        
                                                    }
                                                    
                                                }else{
                                                    // create task for new detail added
                                                    if(!contentIdTaskForDetailMap.containsKey(pConDetail.Placement_Content__c)){
                                                        contentIdTaskForDetailMap.put(pConDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                                    }
                                                    contentIdTaskForDetailMap.get(pConDetail.Placement_Content__c).add(createTask(pConDetail,'Add',false));
                                                }
                                                
                                            }
                                            
                                            if(contentDetailIdMap.keySet().size() > 0){
                                                // create task for details removal
                                                if(!contentIdTaskForDetailMap.containsKey(pCon.Id)){
                                                    contentIdTaskForDetailMap.put(pCon.Id, new List<DGTL_Task__c>());
                                                }
                                                for(Placement_Content_Detail__c pDetail : contentDetailIdMap.values()){
                                                    contentIdTaskForDetailMap.get(pCon.Id).add(createTask(pDetail,'Remove',false));
                                                }
                                            }
                                        }else{
                                            // create task for all details addition
                                            for(Placement_Content_Detail__c pDetail : contentIdDetailsMap.get(pCon.Id)){
                                                if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                                    contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                                }
                                                contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Add',false));
                                            }
                                        }
                                    }else if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(contentToCompareFrom.Id)){
                                        // create task for all details removal
                                        if(!contentIdTaskForDetailMap.containsKey(pCon.Id)){
                                            contentIdTaskForDetailMap.put(pCon.Id, new List<DGTL_Task__c>());
                                        }
                                        for(Placement_Content_Detail__c pDetail : contentIdDetailsMap.get(contentToCompareFrom.Id)){
                                            contentIdTaskForDetailMap.get(pCon.Id).add(createTask(pDetail,'Remove',false));
                                        }
                                    }
                                    //--compare content details ends------
                                    
                                }else{
                                    String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                    changeTypeDayViewMap.put('Add',changeTypeDayViewMap.containsKey('Add') ? 
                                                             changeTypeDayViewMap.get('Add') + '<br/><br/><b>'+ offerType + '</b> - ' + pCon.Main_Message__c : '<b>'+offerType+'</b> -'+ pCon.Main_Message__c);
                                    // create task for new content added
                                    contentIdTaskForContentMap.put(pCon.Id,createTask(pCon,'Add', true));
                                    
                                    if(contentIdDetailsMap.containsKey(pCon.Id)){
                                        for(Placement_Content_Detail__c pDetail : contentIdDetailsMap.get(pCon.Id)){
                                            if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                                contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                            }
                                            contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Add',false));
                                        }
                                    }
                                }
                            }else{
                                 String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                 changeTypeDayViewMap.put('Add',changeTypeDayViewMap.containsKey('Add') ? 
                                                             changeTypeDayViewMap.get('Add') + '<br/><br/><b>'+ offerType + '</b> - ' + pCon.Main_Message__c : '<b>'+offerType+'</b> -'+ pCon.Main_Message__c);
                                // create task for new content added
                                contentIdTaskForContentMap.put(pCon.Id,createTask(pCon,'Add', true));
                                
                                if(contentIdDetailsMap.containsKey(pCon.Id)){
                                    for(Placement_Content_Detail__c pDetail : contentIdDetailsMap.get(pCon.Id)){
                                        if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                            contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                        }
                                        contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Add',false));
                                    }
                                }
                            }  
                        }else{
                            System.debug('===no placement library found!===');
                        }
                    }
                    
                    if(previousContentIdMap.KeySet().size() > 0){
                        // create task for content removals
                        for(Placement_Content__c pCont :previousContentIdMap.values()) {
                            String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                            changeTypeDayViewMap.put('Remove',changeTypeDayViewMap.containsKey('Remove') ? 
                                                             changeTypeDayViewMap.get('Remove') + '<br/><br/><b>'+offerType+ '</b> - ' + pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c);
                            contentIdTaskForContentMap.put(pCont.Id,createTask(pCont,'Remove', true));
                            
                            if(contentIdDetailsMap.containsKey(pCont.Id)){
                                for(Placement_Content_Detail__c pDetail : contentIdDetailsMap.get(pCont.Id)){
                                    if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                        contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                    }
                                    contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Remove',false));
                                }
                            }
                        } 
                    }
                    
                }else{
                    String mainMessages = '';
                    Set<Id> contentIdSet = new Set<Id>();
                     //create task for all removals
                    for(Placement_Content__c pCont :previousLayout.Placement_Content__r) {
                        contentIdSet.add(pCont.Id);
                        String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                        if(changeTypeDayViewMap.containsKey('Remove')){
                            mainMessages = changeTypeDayViewMap.get('Remove');
                        }
                        mainMessages += String.isNotBlank(mainMessages) ? '<br/><br/><b>'+offerType+'</b> -'+pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c;
                        changeTypeDayViewMap.put('Remove',mainMessages);
                        contentIdTaskForContentMap.put(pCont.Id,createTask(pCont,'Remove', true));
                    }
                    
                    if(contentIdSet.size() > 0){
                        List<Placement_Content_Detail__c> detailsList = getPlacementDetails(contentIdSet);
                        if(detailsList.size() > 0){
                            for(Placement_Content_Detail__c pDetail : detailsList){
                                if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                    contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                }
                                contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Remove',false));
                            }  
                        }
                    }
                    
                }
                
            }else if(pLToCompare.Placement_Content__r != null && pLToCompare.Placement_Content__r.size() > 0){
                 String mainMessages = '';
                Set<Id> contentIdSet = new Set<Id>();
                //create task for all addition
                for(Placement_Content__c pCont :pLToCompare.Placement_Content__r) {
                    contentIdSet.add(pCont.Id);
                    String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                    if(changeTypeDayViewMap.containsKey('Add')){
                        mainMessages = changeTypeDayViewMap.get('Add');
                    }
                    mainMessages += String.isNotBlank(mainMessages) ? '<br/><br/><b>'+offerType+'</br> - '+pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c;
                    changeTypeDayViewMap.put('Add',mainMessages);
                    contentIdTaskForContentMap.put(pCont.Id,createTask(pCont,'Add', true));
                }
                
                if(contentIdSet.size() > 0){
                    List<Placement_Content_Detail__c> detailsList = getPlacementDetails(contentIdSet);
                    if(detailsList.size() > 0){
                        if(detailsList.size() > 0){
                            for(Placement_Content_Detail__c pDetail : detailsList){
                                if(!contentIdTaskForDetailMap.containsKey(pDetail.Placement_Content__c)){
                                    contentIdTaskForDetailMap.put(pDetail.Placement_Content__c, new List<DGTL_Task__c>());
                                }
                                contentIdTaskForDetailMap.get(pDetail.Placement_Content__c).add(createTask(pDetail,'Add',false));
                            }  
                        } 
                    }
                }
            }
        }
        
        // set day view task data
        if(changeTypeDayViewMap.size() > 0){
            //previousLayout
            deviceTypeDayViewMap.put(pLToCompare.Device_Type__c,changeTypeDayViewMap);
            layoutDayViewMap.put(pLToCompare.Page_Types__c + editorialPageName,deviceTypeDayViewMap);
            if(!dayViewTaskDataMap.containsKey(pLToCompare.Floorset_Plan__c)) dayViewTaskDataMap.put(pLToCompare.Floorset_Plan__c, new Map<String,Map<String,Map<String,String>>>());
            //System.debug('layoutDayViewMap----'+JSON.serialize(layoutDayViewMap));
            if(dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).containsKey(pLToCompare.Page_Types__c + editorialPageName)){
                if(dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).get(pLToCompare.Page_Types__c + editorialPageName).containsKey(pLToCompare.Device_Type__c)){
                    Map<String,String> deviceMap = dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).get(pLToCompare.Page_Types__c + editorialPageName).get(pLToCompare.Device_Type__c);
                    for(String str : deviceMap.keySet()){
                        if(!changeTypeDayViewMap.containsKey(str)) changeTypeDayViewMap.put(str,'');
                        deviceMap.put(str, deviceMap.get(str) + '<br/><br/>' +changeTypeDayViewMap.get(str));
                    }
                    dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).get(pLToCompare.Page_Types__c + editorialPageName).get(pLToCompare.Device_Type__c).putAll(deviceMap);
                }else{
                    dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).get(pLToCompare.Page_Types__c + editorialPageName).putAll(deviceTypeDayViewMap);
                }
            }else{
                dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).putAll(layoutDayViewMap); 
            }
           
        }
        
        if(sObjListToUpdate != null && sObjListToUpdate.size() > 0){
            update sObjListToUpdate;
        }
        
        //System.debug('contentIdTaskForContentMap---'+JSON.serialize(contentIdTaskForContentMap));
        
        // Insert tasks
        if(contentIdTaskForContentMap.size() > 0){
            insert contentIdTaskForContentMap.values(); // insert content related tasks
            //System.debug('task-----'+JSON.serialize(contentIdTaskForContentMap.values()));
            if(contentIdTaskForDetailMap.keySet().size() > 0){
                
                for(Id contentId : contentIdTaskForDetailMap.keySet()){
                    
                    if(contentIdTaskForContentMap.containsKey(contentId)){
                        for(DGTL_Task__c task : contentIdTaskForDetailMap.get(contentId)){
                            task.Placement_Content__c = contentId;
                            task.Parent_Task__c = contentIdTaskForContentMap.get(contentId).Id;
                            detailTasks.add(task); // collect detail task where parent content task exist
                        }
                        contentIdTaskForDetailMap.remove(contentId);
                    }
                }
            }
        }
                
        if(contentIdTaskForDetailMap.size() > 0){   
            Map<Id,DGTL_Task__c> contentIdTaskMap = new Map<Id,DGTL_Task__c>();
            Set<Id> contentIdSet = contentIdTaskForDetailMap.keySet();
            Map<Id,Placement_Content__c> pcMap = new Map<Id,Placement_Content__c>();
            
            String contentQuery = pContentInnerQuery.toLowerCase().substringBefore('from').remove('(');
            contentQuery += ' from Placement_Content__c WHERE Id IN :contentIdSet';
            
            for(Placement_Content__c pc : Database.query(contentQuery)){
                pcMap.put(pc.Id, pc);
            }
            
            for(Id contentId : contentIdTaskForDetailMap.keySet()){
                String offerType = String.isNotBlank(pcMap.get(contentId).Offer_Type__c) ? pcMap.get(contentId).Offer_Type__c : '';
                changeTypeDayViewMap.put('Update',changeTypeDayViewMap.containsKey('Update') ? 
                                                                 changeTypeDayViewMap.get('Update')+'<br/><br/><b>'+offerType +'</b>'+ pcMap.get(contentId).Main_Message__c : '<b>'+offerType +'</b> - ' + pcMap.get(contentId).Main_Message__c);
                contentIdTaskMap.put(contentId, createTask(pcMap.get(contentId), 'Update', true));
            }
            insert contentIdTaskMap.values(); // insert content task for orphan sub task 
            
            for(Id contentId : contentIdTaskForDetailMap.keySet()){
                for(DGTL_Task__c task : contentIdTaskForDetailMap.get(contentId)){
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
        
        if(layoutTasks.size() > 0){
            insert layoutTasks;
        }

        
    }
    
    public void finish(Database.BatchableContext BC){
        List<DGTL_Task__c> dayViewTasksToInsertList = new List<DGTL_Task__c>();
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Day_View'].Id;
        typeScheduleIntervalMap.remove(pType);
        
        if(dayViewTaskDataMap.size() > 0){
            System.debug('dayViewTaskDataMap====='+JSON.serialize(dayViewTaskDataMap));
            for(Id fPlanId :dayViewTaskDataMap.keySet()){
                DGTL_Task__c task = new DGTL_Task__c(); //assign record type and floorset plan Id.
                task.Floorset_Plan__c = fPlanId;
                task.RecordTypeId = recordTypeId;
                String dayViewTable = '<table border="1" style="border-collapse: collapse"><tr><th>Layout Name</th><th>Add</th><th>Update</th> <th>Remove</th></tr>';
                String desktopRows = '';
                String mobileRows = '';
                     
                    for(String layoutName : dayViewTaskDataMap.get(fPlanId).keySet()){
                        Map<String,Map<String,String>> deviceMap = dayViewTaskDataMap.get(fPlanId).get(layoutName);
                        
                        for(String deviceType : deviceMap.keySet()){
                            
                            String uniqueCombinationKey = fPlanId + '-' + deviceType + '-' + layoutName; 
                            String comparedFrom = comparedFromNameMap.containsKey(uniqueCombinationKey) ? comparedFromNameMap.get(uniqueCombinationKey) : '';
                            
                            String add = deviceMap.get(deviceType).containsKey('Add') ? deviceMap.get(deviceType).get('Add') : '';
                            String updateStr = deviceMap.get(deviceType).containsKey('Update') ? deviceMap.get(deviceType).get('Update') : '';
                            String remove = deviceMap.get(deviceType).containsKey('Remove') ? deviceMap.get(deviceType).get('Remove') : '';
                            
                            String layoutNameWithCompare = String.isNotBlank(comparedFrom) ? layoutName+'<br/><a href="/'+comparedFrom.split('~')[1]+'"> compared with - '+comparedFrom.split('~')[0]+'</a>' : layoutName;
                            
                            if(deviceType.equalsIgnoreCase('Desktop')){
                                desktopRows += '<tr>';
                                desktopRows += '<td>'+layoutNameWithCompare+'</td>';
                                desktopRows += '<td>'+ add +'</td>';
                                desktopRows += '<td>'+ updateStr +'</td>';
                                desktopRows += '<td>'+ remove +'</td>' ;
                                desktopRows += '</tr>';
                            }else{
                                mobileRows += '<tr>';
                                mobileRows += '<td>'+layoutNameWithCompare+'</td>';
                                mobileRows += '<td>'+ add +'</td>';
                                mobileRows += '<td>'+ updateStr +'</td>';
                                mobileRows += '<td>'+ remove +'</td>' ;
                                mobileRows += '</tr>';
                            }
                         }
                     }
                
                task.DeskTop__c = String.isNotBlank(desktopRows) ? dayViewTable + desktopRows + '</table>' : '';
                task.Mobile__c = String.isNotBlank(mobileRows) ? dayViewTable + mobileRows + '</table>' : '';
                System.debug('dayView task----'+task);
                dayViewTasksToInsertList.add(task);
            }
        }
        
        if(dayViewTasksToInsertList.size() > 0){
            insert dayViewTasksToInsertList;
        }
        
        if(typeScheduleIntervalMap != null && typeScheduleIntervalMap.keySet().size() > 0){
            // call for another type
            Database.executeBatch(new DGTL_TaskManagerScheduledBatch(brand,typeScheduleIntervalMap),1); // batch size will be 1 to process one layout comparison at a time.
        }
    }
    
    
    //schedulable context 
    public void execute(SchedulableContext SC) {
        Map<String,Map<String,Integer>> brandTypeScheduleIntervalMap = new Map<String,Map<String,Integer>>();
        
        for(DGTL_Access_Management__c accMngmt : [SELECT Type__c,Brands__c,Schedule_Interval__c 
                                                  FROM DGTL_Access_Management__c 
                                                  WHERE RecordType.DeveloperName = 'Schedule' AND Type__c != null])
        {
            if(!brandTypeScheduleIntervalMap.containsKey(accMngmt.Brands__c)){
                brandTypeScheduleIntervalMap.put(accMngmt.Brands__c, new Map<String,Integer>());
            }
            brandTypeScheduleIntervalMap.get(accMngmt.Brands__c).put(accMngmt.Type__c,accMngmt.Schedule_Interval__c != null ? Integer.valueOf(accMngmt.Schedule_Interval__c) : 0);
        }
        
        if(brandTypeScheduleIntervalMap.keySet().size() > 0){
            for(String brand :brandTypeScheduleIntervalMap.keySet()){
                Database.executeBatch(new DGTL_TaskManagerScheduledBatch(brand,brandTypeScheduleIntervalMap.get(brand)),1); // batch size will be 1 to process one layout comparison at a time.
            }
        }
        
    }
    
    /*
    *  @author  Vipul Mittal 
    *  @ get the latest floorset plan ids based on schedule interval
    *  @param DateTime - constructed from no. of hours given in the Access Management
    *  @return  Set<Id> - Set of Floorset/Update ids   
    */
    public Set<Id> getFloorsetPlanIds(DateTime dtTimeAsPerScheduleInterval){
        Date scheduledDate = Date.newinstance(dtTimeAsPerScheduleInterval.year(), dtTimeAsPerScheduleInterval.month(), dtTimeAsPerScheduleInterval.day());
        Date nextOfScheduleDate = scheduledDate.addDays(1);
        Integer taskMilestoneHour = String.isNotBlank(DGTL_ErrorMessages__c.getValues('Task Milestone Hour').Error_Message__c) ? 
            Integer.valueOf(DGTL_ErrorMessages__c.getValues('Task Milestone Hour').Error_Message__c) : null;
            
        Set<Id> fPlanIds = new Set<Id>();
        for(DGTL_Floorset_Plan__c fPlan : [SELECT Id,Time__c,Date__c FROM DGTL_Floorset_Plan__c 
                                           WHERE Brands__c = :brand AND Type__c = :pType 
                                           AND (Date__c = :scheduledDate OR Date__c = :nextOfScheduleDate) 
                                          ORDER By Date__c]) 
        {
            if(fPlan.Date__c != nextOfScheduleDate || 
               (fPlan.Date__c == nextOfScheduleDate && taskMilestoneHour != null && 
                String.isNotBlank(fPlan.Time__c) && getHourNumber(fPlan.Time__c) < taskMilestoneHour )) 
            {
                fPlanIds.add(fPlan.Id);
            }
        }
        
        System.debug('fPlanIds====='+fPlanIds);
        return fPlanIds;      
        
    }
    
    /*
    *  @author  Vipul Mittal 
    *  @ get exact hour number value from string like 5AM,5PM
    *  @param String - hour string like 5AM,5PM
    *  @return  Integer - converts and returns the hour string in 24 hour format number like 5,17  
    */
    public Integer getHourNumber(String hourString){
        Integer hourNumber = 0;
        if(hourString.containsIgnoreCase('PM')){
            hourString = hourString.remove('PM').trim();
            hourNumber = Integer.valueOf(hourString) + 12;
        }else{
             hourNumber = Integer.valueOf(hourString.remove('AM').trim());
        }
        
        return hourNumber;
    }
    
    /*
    *  @author  Vipul Mittal 
    *  @ get all the fields to compare from access management
    *  @param String - object api name
    *  @return  Set<String> - returns a set of field api name from  Access Management for the given object.
    */ 
    public Set<String> getFieldsToCompare(String objName){
        Set<String> fieldsToCompare = new Set<String>();
        DGTL_Access_Management__c accessMgmt;
        
        try{
            accessMgmt = [SELECT Read_Only_Fields__c FROM DGTL_Access_Management__c 
                          WHERE RecordType.DeveloperName = 'Compare_Setup' 
                          AND Object_Name__c = :objName 
                          AND UserOrProfileId__c = null  
                          AND Brands__c = :brand LIMIT 1];
        }catch(QueryException qe){
            System.debug('No Compare Setup Found!'); 
        }
        
        if(accessMgmt != null && String.isNotBlank(accessMgmt.Read_Only_Fields__c)){
            for(String str :accessMgmt.Read_Only_Fields__c.split(';') ){
                fieldsToCompare.add(str.toLowerCase());
            }
           
        }else{
            System.debug('No Compare Setup Found!');
        }
        
        System.debug('fieldsToCompare======'+fieldsToCompare);
        
        return fieldsToCompare;
    }
    
    /*
    *  @author  Vipul Mittal 
    *  @ get all the fields to compare from access management
    *  @param sObject obj, String compareType, Boolean isContent - 
    *  @return  Set<String> - returns a set of field api name from  Access Management for the given object.
    */ 
    public DGTL_Task__c createTask(sObject obj, String compareType, Boolean isContent){
        DGTL_Task__c task = new DGTL_Task__c();
        Schema.FieldSet fs;
        
        if(taskRecordTypeId == null){
            taskRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='DGTL_Task__c' AND DeveloperName='User_Task'].Id;
        }
        
        task.RecordTypeId = taskRecordTypeId;
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
    
    /*
    *  @author  Vipul Mittal 
    *  @ get the placement content details for the provided content ids.
    *  @param Set<Id>   Set of content ids.
    *  @return  List<Placement_Content_Detail__c> - Returns list of Placement Content Detail.   
    */
    public List<Placement_Content_Detail__c> getPlacementDetails(Set<Id> contentIdSet){
        List<Placement_Content_Detail__c> detailsList  = new List<Placement_Content_Detail__c>();
        Set<String> detailFieldsToCompare = new Set<String>{'Copy__c','Link_Text__c','Sub_Type__c','Slides__c'};
        if(Test.isRunningTest()) detailFieldsToCompare.add('Asset_Path__c'); // as the fields are hard-coded
        Set<String> detFieldsToQuery = new Set<String>();
        detFieldsToQuery.addAll(detailFieldsToCompare);
        for(Schema.FieldSetMember f : Schema.SObjectType.Placement_Content_Detail__c.fieldSets.DGTL_Task_Mapping.getFields()) {
            detFieldsToQuery.add(f.getFieldPath());
        }
        System.debug('detFieldsToQuery-----'+JSON.serialize(detFieldsToQuery));
        String cDetailQueryFields = String.join(new List<String>(detFieldsToQuery), ', ');
        
        for(Placement_Content_Detail__c pcDetail : Database.query('SELECT Id,Name, Placement_Content__c,'+cDetailQueryFields+' FROM Placement_Content_Detail__c WHERE Placement_Content__c IN : contentIdSet ORDER BY CreatedDate DESC '))
        {
            detailsList.add(pcDetail);
        }
        return detailsList;
    }
    
    
}