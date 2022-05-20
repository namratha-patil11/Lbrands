public class DGTL_DayViewTaskScheduledBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    private FieldsToCompare flsToCompare;
    private String pContentInnerQuery;
    private Map<String,String> comparedFromNameMap; 
    private Map<Id,Map<String,Map<String,Map<String,String>>>> dayViewTaskDataMap;
    private Set<Id> comparedContents;
    
    public DGTL_DayViewTaskScheduledBatch(){
        dayViewTaskDataMap = new Map<Id,Map<String,Map<String,Map<String,String>>>>();
        comparedFromNameMap = new Map<String,String>();
        comparedContents = new Set<Id>();
    }
    
    public Database.querylocator start(Database.BatchableContext BC){
        Set<Id> fPlanIds = getFloorsetPlanIds();
        flsToCompare =  getFieldsToCompare('Placement_Content__c');
        Set<String> contentFieldsToQuery = new Set<String>();
        
        if(fPlanIds != null && fPlanIds.size() > 0){
            contentFieldsToQuery.addAll(flsToCompare.fieldToCompareSet);
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
            pContentFields = !contentFieldsToQuery.contains('offer_type__c') ? pContentFields+'Offer_Type__c,' : pContentFields;
            pContentFields = !contentFieldsToQuery.contains('ab_test_name__c') ? pContentFields+'AB_Test_Name__c,' : pContentFields;
            
            pContentFields += String.join(new List<String>(contentFieldsToQuery), ', ');
            
            pContentInnerQuery = '(SELECT KOD__r.Digital_Offer_Disclaimer__c,Compare_Type__c,Placement_Library__r.Name,'+pContentFields+' FROM Placement_Content__r WHERE Active__c = true AND (Type__c = \'Controlled\' OR Type__c = \'Takedown\' OR Type__c = \'AB Test\' OR Type__c = \'Contingency\') ORDER BY S_No__c)';
            
            if(!Test.isRunningTest()){
                return Database.getQueryLocator('SELECT Id,Name,Collection_Page_Url__c,Collection_Page_Name__c,Page_Types__c,Floorset_Plan__c,Brands__c,Time_No__c,Device_Type__c,Date_Formula__c, '+pContentInnerQuery+' FROM Placement_Layout__c WHERE Floorset_Plan__c IN :fPlanIds AND Type__c = \'Layout\' AND Is_Deleted__c != true order by Floorset_Plan__c,Page_Types__c,Device_Type__c');
            }else{
                // required as the data is based on LastModifiedDate and need atleast two records to process execute logic
                return Database.getQueryLocator('SELECT Id,Name,Collection_Page_Url__c,Collection_Page_Name__c,Page_Types__c,Floorset_Plan__c,Brands__c,Time_No__c,Device_Type__c,Date_Formula__c, '+pContentInnerQuery+' FROM Placement_Layout__c WHERE Floorset_Plan__c IN :fPlanIds AND Type__c = \'Layout\' AND Is_Deleted__c != true order by Floorset_Plan__c,Page_Types__c,Device_Type__c LIMIT 1');
            }
        }else{
            return Database.getQueryLocator('SELECT Id FROM Placement_Layout__c LIMIT 0');
        }
        
    }
    
    public void execute(Database.BatchableContext BC, List<Placement_Layout__c> scope){
        Set<String> detailFieldsToCompare;
        
        Map<Placement_Layout__c,Placement_Layout__c> plToCompareAndPreviousMap = new Map<Placement_Layout__c,Placement_Layout__c>();
        Set<Placement_Content__c> placementContentsToUpdateList = new Set<Placement_Content__c>();
        
        Placement_Layout__c pLToCompare = scope[0]; // since batch size will always be one
        Date dateFormula =  pLToCompare.Date_Formula__c;
        String pageType = pLToCompare.Page_Types__c;
        String deviceType = pLToCompare.Device_Type__c;
        String brands = pLToCompare.Brands__c;
        String editorialName = pLToCompare.Collection_Page_Name__c != null ? pLToCompare.Collection_Page_Name__c : null;
        Id plToCompareId = pLToCompare.Id;
        System.debug('pLToCompare======'+pLToCompare);
        
        String editorialPageName = pLToCompare.Page_Types__c == 'Editorials' && String.isNotBlank(pLToCompare.Collection_Page_Name__c) 
                        ? ' - ' + pLToCompare.Collection_Page_Name__c : '';
        
        try{
            String query = 'SELECT Id,Name,Collection_Page_Url__c,Collection_Page_Name__c,Page_Types__c,Floorset_Plan__c,Brands__c,Time_No__c,Device_Type__c,Date_Formula__c,'+pContentInnerQuery+' FROM Placement_Layout__c WHERE Date_Formula__c <= :dateFormula';
            query += ' AND Brands__c = :brands AND Is_Deleted__c = false AND Type__c = \'Layout\' AND Collection_Page_Name__c = :editorialName';
            query += ' AND Page_Types__c = :pageType AND Device_Type__c =:deviceType ORDER BY Date_Formula__c DESC,Time_No__c DESC LIMIT 10';
            
            // get the immediate previous layout to compare
            for(Placement_Layout__c pLay : Database.query(query)){
                if( (pLay.Date_Formula__c == pLToCompare.Date_Formula__c && pLay.Time_No__c < pLToCompare.Time_No__c) || pLay.Date_Formula__c < pLToCompare.Date_Formula__c){
                    plToCompareAndPreviousMap.put(scope[0],pLay);
                    break;
                }
            }
            
            // get the immediate next layout to compare 
            String queryForNext = 'SELECT Id,Name,Collection_Page_Url__c,Collection_Page_Name__c,Page_Types__c,Floorset_Plan__c,Brands__c,Time_No__c,Device_Type__c,Date_Formula__c,'+pContentInnerQuery+' FROM Placement_Layout__c WHERE Date_Formula__c >= :dateFormula';
            queryForNext += ' AND Brands__c = :brands AND Is_Deleted__c = false AND Type__c = \'Layout\' AND Collection_Page_Name__c = :editorialName';
            queryForNext += ' AND Page_Types__c = :pageType AND Device_Type__c =:deviceType AND Id != :plToCompareId ORDER BY Date_Formula__c ASC, Time_No__c ASC LIMIT 1';
            
            Placement_Layout__c pLayNext =  Database.query(queryForNext);
            plToCompareAndPreviousMap.put(pLayNext,scope[0]);
            
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
        
        for(Placement_Layout__c pLayout : plToCompareAndPreviousMap.keySet()){
            if(!comparedContents.contains(pLayout.Id)){
                Map<String,Map<String,Map<String,String>>> layoutDayViewMap = new Map<String,Map<String,Map<String,String>>>();
                Map<String,Map<String,String>> deviceTypeDayViewMap = new Map<String,Map<String,String>>();
                Map<String,String> changeTypeDayViewMap = new Map<String,String>();
                comparedContents.add(pLayout.Id);
                Placement_Layout__c previousLayout = plToCompareAndPreviousMap.get(pLayout);
                pLToCompare = pLayout;
                String combinationValue = pLToCompare.Id;
               /* if(previousLayout != null && String.isNotBlank(previousLayout.Collection_Page_Url__c) && 
                   String.isNotBlank(pLayout.Collection_Page_Url__c) && 
                   pLayout.Collection_Page_Url__c != previousLayout.Collection_Page_Url__c)
                {
                    //create Task -- not required for Daily Changes
                }*/
                
                if(previousLayout != null && flsToCompare.brandVSFieldsToCompareMap.containsKey(brands)){
                    combinationValue += '~'+previousLayout.Name+'~'+previousLayout.Id;
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
                                
                                //System.debug('detFieldsToQuery-----'+JSON.serialize(detFieldsToQuery));
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
                                Boolean createTask = false;
                                if(pCon.Placement_Library__c != null ){
                                    if(pLibraryPreviousContentsMap.containsKey(pCon.Placement_Library__c+'-'+pCon.Type__c+'-'+abTestName)){
                                        System.debug('library detected====');
                                        Placement_Content__c contentToCompareFrom;
                                        
                                        // get the old content to compare based on library
                                        for(Placement_Content__c pCont : pLibraryPreviousContentsMap.get(pCon.Placement_Library__c+'-'+pCon.Type__c+'-'+abTestName)){
                                            if(previousContentIdMap.containsKey(pCont.Id)){
                                                contentToCompareFrom = pCont;
                                                previousContentIdMap.remove(pCont.Id);
                                                break;
                                            }
                                        }
                                        System.debug('contentToCompareFrom-----'+contentToCompareFrom);
                                        if(contentToCompareFrom != null){
                                            String changedContentFieldLabels = '';
                                            Boolean isChanged = false;
                                            
                                            // compare content fields
                                            for(String field : flsToCompare.brandVSFieldsToCompareMap.get(brands)){
                                                System.debug('field-----'+field);
                                                System.debug('pCon.get(field)----'+pCon.get(field));
                                                System.debug('contentToCompareFrom.get(field)----'+contentToCompareFrom.get(field));
                                                if(pCon.get(field) != contentToCompareFrom.get(field)){
                                                    isChanged = true;
                                                    field = field.endsWith('__c') ? field.removeEnd('__c') :field;
                                                    field = field.contains('_') ? field.replace('_',' ') : field;
                                                    changedContentFieldLabels += field + ', ';
                                                }
                                            }
                                            
                                            if(isChanged){
                                                createTask = true;
                                            }
                                            
                                            //---compare content details starts----'
                                            List<Placement_Content_Detail__c> oldPLDetailsList = contentIdDetailsMap.get(contentToCompareFrom.Id);
                                            if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCon.Id)){
                                                
                                                if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(contentToCompareFrom.Id)){
                                                    Integer recCount = 0;
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
                                                            if( (oldDetail.Slides__c + oldDetail.Link_Text__c + oldDetail.Sub_Type__c + oldDetail.Copy__c) == (pConDetail.Slides__c + pConDetail.Link_Text__c + pConDetail.Sub_Type__c + pConDetail.Copy__c) && contentDetailIdMap.containsKey(oldDetail.Id)){
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
                                                                createTask = true;   
                                                            }
                                                            
                                                        }else{
                                                            createTask = true;
                                                        }
                                                        
                                                    }
                                                    
                                                    if(contentDetailIdMap.keySet().size() > 0){
                                                        createTask = true;
                                                    }
                                                }else{
                                                    createTask = true;
                                                }
                                            }else if(contentIdDetailsMap != null && !contentIdDetailsMap.containsKey(contentToCompareFrom.Id) && oldPLDetailsList != null && oldPLDetailsList.size() > 0){
                                                createTask = true;
                                            }
                                            
                                            if(createTask){
                                                String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                                if(String.isBlank(pCon.Compare_Type__c) || pCon.Compare_Type__c != 'Update'){
                                                    pCon.Compare_Type__c = 'Update';
                                                    placementContentsToUpdateList.add(pCon);
                                                }
                                                changeTypeDayViewMap.put('Update',changeTypeDayViewMap.containsKey('Update') ? 
                                                                         changeTypeDayViewMap.get('Update')+'<br/><br/> <b>'+ offerType + '</b> - ' + pCon.Main_Message__c :  
                                                                         '<b>'+ offerType + '</b> - ' + pCon.Main_Message__c);
                                            }else{
                                                pCon.Compare_Type__c = '';
                                                placementContentsToUpdateList.add(pCon);
                                            }
                                            //--compare content details ends------
                                            
                                        }else{
                                            String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                            if(String.isBlank(pCon.Compare_Type__c) || pCon.Compare_Type__c != 'Add'){
                                                pCon.Compare_Type__c = 'Add';
                                                placementContentsToUpdateList.add(pCon);
                                            }
                                            changeTypeDayViewMap.put('Add',changeTypeDayViewMap.containsKey('Add') ? 
                                                                     changeTypeDayViewMap.get('Add') + '<br/><br/><b>'+ offerType + '</b> - ' + pCon.Main_Message__c : '<b>'+offerType+'</b> -'+ pCon.Main_Message__c);
                                        }
                                    }else{
                                        String offerType = String.isNotBlank(pCon.Offer_Type__c) ? pCon.Offer_Type__c : '';
                                        if(String.isBlank(pCon.Compare_Type__c) || pCon.Compare_Type__c != 'Add'){
                                            pCon.Compare_Type__c = 'Add';
                                            placementContentsToUpdateList.add(pCon);
                                        }
                                        changeTypeDayViewMap.put('Add',changeTypeDayViewMap.containsKey('Add') ? 
                                                                 changeTypeDayViewMap.get('Add') + '<br/><br/><b>'+ offerType + '</b> - ' + pCon.Main_Message__c : '<b>'+offerType+'</b> -'+ pCon.Main_Message__c);
                                        
                                    }  
                                }else{
                                    System.debug('===no placement library found!===');
                                }
                            }
                            
                            if(previousContentIdMap.KeySet().size() > 0){
                                // create task for content removals
                                for(Placement_Content__c pCont :previousContentIdMap.values()) {
                                    /*if(String.isBlank(pCont.Compare_Type__c) || pCont.Compare_Type__c != 'Remove'){
                                        pCont.Compare_Type__c = 'Remove';
                                        placementContentsToUpdateList.add(pCont);
                                    }*/
                                    String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                                    changeTypeDayViewMap.put('Remove',changeTypeDayViewMap.containsKey('Remove') ? 
                                                             changeTypeDayViewMap.get('Remove') + '<br/><br/><b>'+offerType+ '</b> - ' + pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c);
                                } 
                            }
                            
                        }else{
                            String mainMessages = '';
                            //create task for all removals
                            for(Placement_Content__c pCont :previousLayout.Placement_Content__r) {
                                /*if(String.isBlank(pCont.Compare_Type__c) || pCont.Compare_Type__c != 'Remove'){
                                    pCont.Compare_Type__c = 'Remove';
                                    placementContentsToUpdateList.add(pCont);
                                }*/
                                String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                                if(changeTypeDayViewMap.containsKey('Remove')){
                                    mainMessages = changeTypeDayViewMap.get('Remove');
                                }
                                mainMessages += String.isNotBlank(mainMessages) ? '<br/><br/><b>'+offerType+'</b> -'+pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c;
                                changeTypeDayViewMap.put('Remove',mainMessages);
                            }
                        }
                        
                    }else if(pLToCompare.Placement_Content__r != null && pLToCompare.Placement_Content__r.size() > 0){
                        String mainMessages = '';
                        //create task for all addition
                        for(Placement_Content__c pCont :pLToCompare.Placement_Content__r) {
                            if(String.isBlank(pCont.Compare_Type__c) || pCont.Compare_Type__c != 'Add'){
                                pCont.Compare_Type__c = 'Add';
                                placementContentsToUpdateList.add(pCont);
                            }
                            String offerType = String.isNotBlank(pCont.Offer_Type__c) ? pCont.Offer_Type__c : '';
                            if(changeTypeDayViewMap.containsKey('Add')){
                                mainMessages = changeTypeDayViewMap.get('Add');
                            }
                            mainMessages += String.isNotBlank(mainMessages) ? '<br/><br/><b>'+offerType+'</br> - '+pCont.Main_Message__c : '<b>'+offerType+'</b> - '+pCont.Main_Message__c;
                            changeTypeDayViewMap.put('Add',mainMessages);
                        }
                    }
                }
                
                // set day view task data
                if(changeTypeDayViewMap.size() > 0){
                    comparedFromNameMap.put(pLToCompare.Floorset_Plan__c + '-' + pLToCompare.Device_Type__c + '-' + pLToCompare.Page_Types__c+editorialPageName, combinationValue);
                    deviceTypeDayViewMap.put(pLToCompare.Device_Type__c,changeTypeDayViewMap);
                    layoutDayViewMap.put(pLToCompare.Page_Types__c + editorialPageName,deviceTypeDayViewMap);
                    if(!dayViewTaskDataMap.containsKey(pLToCompare.Floorset_Plan__c)) dayViewTaskDataMap.put(pLToCompare.Floorset_Plan__c, new Map<String,Map<String,Map<String,String>>>());
                    //System.debug('layoutDayViewMap----'+JSON.serialize(layoutDayViewMap));
                    if(dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).containsKey(pLToCompare.Page_Types__c + editorialPageName)){
                        if(dayViewTaskDataMap.get(pLToCompare.Floorset_Plan__c).get(pLToCompare.Page_Types__c  + editorialPageName).containsKey(pLToCompare.Device_Type__c)){
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
            }
        }
        System.debug('placementContentsToUpdateList-----'+placementContentsToUpdateList);
        if(placementContentsToUpdateList.size() > 0) update new List<Placement_Content__c>(placementContentsToUpdateList);
    }
    
    public void finish(Database.BatchableContext BC){
        Set<Id> floorsetPlanIdSet = new Set<Id>(dayViewTaskDataMap.keySet());
        List<DGTL_Task__c> dayViewTasksToInsertList = new List<DGTL_Task__c>();
        
        if(floorsetPlanIdSet.size() > 0){
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='Day_View'].Id;
            
            //Delete old day view task if exist
            DELETE[SELECT Id FROM DGTL_Task__c WHERE Floorset_Plan__c IN:floorsetPlanIdSet AND RecordTypeId=:recordTypeId];
            
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
                        String comparedRecDetail = comparedFromNameMap.containsKey(uniqueCombinationKey) ? comparedFromNameMap.get(uniqueCombinationKey) : '';
                        String currentRecId = comparedRecDetail.contains('~') ? comparedRecDetail.split('~')[0] : comparedRecDetail;
                        String comparedFrom = comparedRecDetail.contains('~') ? comparedRecDetail.split('~')[1] + '~' + comparedRecDetail.split('~')[2] : '';
                        String add = deviceMap.get(deviceType).containsKey('Add') ? deviceMap.get(deviceType).get('Add') : '';
                        String updateStr = deviceMap.get(deviceType).containsKey('Update') ? deviceMap.get(deviceType).get('Update') : '';
                        String remove = deviceMap.get(deviceType).containsKey('Remove') ? deviceMap.get(deviceType).get('Remove') : '';
                        
                        String layoutNameWithCompare = String.isNotBlank(comparedFrom) ? 
                            '<a href="/'+currentRecId+'">'+layoutName+'</a>'+'<br/>compared with - '+comparedFrom.split('~')[0]+'</a>' :
                        	'<a href="/'+currentRecId+'">'+layoutName+'</a>';
                       
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
    }
    
    //schedule 
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new DGTL_DayViewTaskScheduledBatch(),1); // batch size will be 1 to process one layout comparison at a time.
    }
    
    public Set<Id> getFloorsetPlanIds(){
        Set<Id> floorsetIdSet = new Set<Id>();
        for(Placement_Layout__c pl : [SELECT Floorset_Plan__c FROM Placement_Layout__c 
                                      WHERE LastModifiedDate = today 
                                      AND Floorset_Plan__c != null])
        {
            floorsetIdSet.add(pl.Floorset_Plan__c);
        }
        return floorsetIdSet;
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
    
    public class FieldsToCompare{
        public Set<String> fieldToCompareSet;
        public Map<String,Set<String>> brandVSFieldsToCompareMap;
    }
    
}
