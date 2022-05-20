/*****
This class is controller for DGTL_ViewPlcLayout.cmp
****/
public class DGTL_ViewPlcLayout_Controller {
    
    /*
      *   This Method is used to get logged in user brand
      *   Component helper method : getUserBrandHpr
      */
    @AuraEnabled
    public static string getUserBrandHpr()
    {
       return DGTL_DataAccessor.getUserBrand(); 
        
    }
    @AuraEnabled
    public static resultWprNew fetchContentNew(String selectedBrand, String pageType, date dateVal, Decimal timeVal, String floorsetId, String searchNextBack, date snapShotDate, String deviceType)
    {
        system.debug('input recieved====='+selectedBrand + '--'+pageType+'--' + dateVal +'--'+ floorsetId + '--'+ searchNextBack+'--'+snapShotDate+'---'+deviceType);
        Set<Id> list_layIds = new Set<Id>();
        List<String> rdfieldsList = New List<String>();
        List<String> allfieldsList = New List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType contentSchema = schemaMap.get('Placement_Content__c');
        Map<String, Schema.SObjectField> fieldMap = contentSchema.getDescribe().fields.getMap();
        Map<String,String> readFieldsMap = New Map<String,String>();
        List<contentWpr> list_plcContents = new List<contentWpr>();
        List<layoutWpr> list_plcLayouts = new List<layoutWpr>();
        List<Placement_Content__c> placeContList = new List<Placement_Content__c>();
        resultWprNew rWpr = new resultWprNew();
        rWpr.cDetailsReadFieldMap = new Map<String,String>();
        DGTL_Access_Management__c accessMng = new DGTL_Access_Management__c();
        DGTL_Floorset_Plan__c  obj_FloorSetPlan = New DGTL_Floorset_Plan__c();
        String layoutType = '';
        
        //Select the layout type
        layoutType = String.isNotBlank((String.valueOf(snapShotDate))) ? 'Snapshot' : 'Layout';
        
        String strSoql = 'SELECT Id,Placement_Layout__c,Image__c,Placement_Library__c ';   
        If(searchNextBack=='Search'){
            obj_FloorSetPlan = [SELECT Id,Date__c,Time__c,Time_No__c FROM DGTL_Floorset_Plan__c WHERE Id=:floorsetId];
            dateVal = obj_FloorSetPlan.Date__c;
            timeVal = obj_FloorSetPlan.Time_No__c;
        }else if(searchNextBack=='Next' ){
            system.debug('next --dateVal--'+dateVal);
            for(DGTL_Floorset_Plan__c flr : [SELECT Id,Date__c,Time__c,Time_No__c 
                                             FROM DGTL_Floorset_Plan__c WHERE Date__c >=:dateVal 
                                             AND Id!=:floorsetId order by Date__c ])
            {	
                system.debug('flr------'+flr);
                if(flr.Date__c == dateVal && flr.Time_No__c > timeVal)
                {
                    obj_FloorSetPlan = flr;
                    dateVal = obj_FloorSetPlan.Date__c;
                    timeVal = obj_FloorSetPlan.Time_No__c;
                    break;
                }else if(flr.Date__c > dateVal){
                    obj_FloorSetPlan = flr;
                    dateVal = obj_FloorSetPlan.Date__c;
                    timeVal = obj_FloorSetPlan.Time_No__c;
                    break;
                }
            }
        }
        else if(searchNextBack=='Back' ){
            system.debug('back --dateVal--'+dateVal);
            for(DGTL_Floorset_Plan__c flr : [SELECT Id,Date__c,Time__c,Time_No__c FROM 
                                             DGTL_Floorset_Plan__c WHERE Date__c <=:dateVal
                                             AND Id!=:floorsetId order by Date__c  desc ])
            {
                if(flr.Date__c == dateVal && flr.Time_No__c < timeVal)
                {
                    obj_FloorSetPlan = flr;
                    dateVal = obj_FloorSetPlan.Date__c;
                    timeVal = obj_FloorSetPlan.Time_No__c;
                    break;
                }else if(flr.Date__c < dateVal){
                    obj_FloorSetPlan = flr;
                    dateVal = obj_FloorSetPlan.Date__c;
                    timeVal = obj_FloorSetPlan.Time_No__c;
                    break;
                }
            }
        }
        If(obj_FloorSetPlan.Id != Null){
            rWpr.dateVal  = obj_FloorSetPlan.Date__c;
            rWpr.timeVal = obj_FloorSetPlan.Time_No__c;
            rWpr.timeValStr = obj_FloorSetPlan.Time__c;
            rWpr.list_PlacLyt[0].Floorset_Plan__c = obj_FloorSetPlan.Id;
            rWpr.list_PlacLyt[0].Brands__c = selectedBrand;
            rWpr.list_PlacLyt[0].Page_Types__c = String.isNotBlank(pageType)? pageType : '';
            rWpr.selectedFloorset = obj_FloorSetPlan.Id;
            system.debug('rWpr.selectedFloorset-----'+rWpr.selectedFloorset);
        } 
        User userRec = new User();
        userRec = [SELECT id, name , DGTL_Profile__c from User where id =: UserInfo.getUserId() LIMIT 1];
        for(DGTL_Access_Management__c AM : [SELECT id,Object_Name__c,Page_Type__c,Team__c,Read_Only_Fields__c,UserOrProfile__c,
                                            UserOrProfileId__c,Tab_Name__c,Brands__c FROM DGTL_Access_Management__c 
                                            WHERE  Object_Name__c = 'Placement_Content__c' 
                                            AND recordTypeId IN (Select Id From RecordType 
                                                                 WHERE sobjecttype = 'DGTL_Access_Management__c' 
                                                                 AND developerName='View_Management')
                                            AND Tab_Name__c = 'DGTL View'
                                            AND (UserOrProfileId__c=:UserInfo.getUserId() OR UserOrProfileId__c=:UserInfo.getProfileId() 
                                                 or Team__c =: userRec.DGTL_Profile__c) 
                                            AND Brands__c=:selectedBrand order BY Page_Type__c DESC])
        {
            if(AM.UserOrProfileId__c == UserInfo.getUserId()){
                accessMng = AM;
                break;                
            }
            else if(AM.UserOrProfileId__c == UserInfo.getProfileId()) accessMng = AM;
            else if(AM.Team__c == userRec.DGTL_Profile__c) accessMng = AM;
        }
        
        if(string.IsNotBlank(accessMng.Read_Only_Fields__c)){
            rdfieldsList = accessMng.Read_Only_Fields__c.split(';');
        }
        //System.debug('accessMng---'+JSON.serialize(accessMng));
        //System.debug('rdfieldsList----'+JSON.serialize(rdfieldsList));
        for(string s : rdfieldsList){
            readFieldsMap.put(s,fieldMap.get(s).getDescribe().getLabel());
            allfieldsList.add(s);
            if(!strSoql.contains(s)) strSoql += ',' + s;
        }
        
        // for displaying name in view Tab
		if(!strSoql.containsIgnoreCase('Placement_type__c'))      strSoql += ',' + 'Placement_type__c';  
        if(!strSoql.containsIgnoreCase('Main_Message__c'))      strSoql += ',' + 'Main_Message__c';  
        if(!strSoql.containsIgnoreCase('Time_Period__c'))      strSoql += ',' + 'Time_Period__c';  

        system.debug(pageType+'--' +dateVal+'--'+selectedBrand );
        
        rWpr.readFieldsMap = readFieldsMap;
        Id floorsetIdNew = obj_FloorSetPlan.Id;
        
        //Fetch Layout Block        
        String layoutListQuery = 'SELECT Id,Collection_Page_Url__c,Date_Formula__c,Brands__c,Page_Types__c,Time_No__c,Device_Type__c,Snapshot_Date__c,Collection_Page_Name__c,('+ strSoql + ' FROM Placement_Content__r WHERE Type__c != \'Escalation\' AND Active__c = TRUE order by Placement_Layout__c,S_No__c) FROM  Placement_Layout__c';
        layoutListQuery += ' WHERE Is_Deleted__c = false AND Floorset_Plan__c =:floorsetIdNew';
        layoutListQuery += ' AND Type__c=:layoutType';
        layoutListQuery += String.isNotBlank(deviceType) ? ' AND Device_Type__c=: deviceType' : '';
        layoutListQuery += String.isNotBlank(pageType) ? ' AND Page_Types__c=: pageType' : '' ;        
        if(layoutType =='Snapshot'){
            String dateSnapshotString = String.valueOf(snapShotDate).substringBefore(' ');
            system.debug('dateSnapshotString...'+dateSnapshotString);
            layoutListQuery +=' AND Snapshot_Date__c<='+dateSnapshotString+' Order by Snapshot_Date__c desc LIMIT 1 ';
        }
        
        list<Placement_Layout__c> layoutList = new list<Placement_Layout__c>();
        Set<Id> pContentIds = new Set<Id>();
        Map<Id,List<Placement_Content_Detail__c>> contentIdDetailsMap;
        system.debug('layoutListQuery--'+layoutListQuery);
        layoutList = Database.query(layoutListQuery);
        system.debug('layoutListQuery---'+layoutListQuery);
        
        // collect the content Ids to query content Details
        for(Placement_Layout__c pLay : layoutList){
            for(Placement_Content__c pCon : pLay.Placement_Content__r){
                pContentIds.add(pCon.Id);
            }
        }
        
        if(pContentIds.size() > 0){
            DGTL_Access_Management__c accessMgmt;
            try{
                accessMgmt = [SELECT Read_Only_Fields__c FROM DGTL_Access_Management__c 
                              WHERE RecordType.DeveloperName = 'View_Management' 
                              AND Object_Name__c = 'Placement_Content_Detail__c' 
                              AND Brands__c = :selectedBrand 
                              AND (UserOrProfileId__c=:UserInfo.getUserId() OR UserOrProfileId__c=:UserInfo.getProfileId() 
                                   or Team__c =: userRec.DGTL_Profile__c) 
                              order BY Page_Type__c DESC LIMIT 1];
            }catch(QueryException qe){
                throw new AuraException('No View Setup Found!'); //TODO:
            }
            
            if(accessMgmt != null){
                for(String str :accessMgmt.Read_Only_Fields__c.split(';')){
                    String fieldLabel = str.endsWith('__c') ? str.removeEnd('__c') :str;
                    fieldLabel = fieldLabel.contains('_') ? fieldLabel.replace('_',' ') : fieldLabel;
                    rWpr.cDetailsReadFieldMap.put(str,fieldLabel); 
                }
            }else{
                 throw new AuraException('No View Setup Found!');//TODO:
            }
            
            if(rWpr.cDetailsReadFieldMap.keySet().size() > 0){
                contentIdDetailsMap = new Map<Id,List<Placement_Content_Detail__c>>();
                String fieldsToQuery =String.join(new List<String>(rWpr.cDetailsReadFieldMap.keySet()), ', ');
                fieldsToQuery = !fieldsToQuery.contains('Placement_Content__c') ? fieldsToQuery + ',Placement_Content__c' : fieldsToQuery;
                System.debug('fieldsToQuery------'+fieldsToQuery);
                for(Placement_Content_Detail__c pcDetail : Database.query('SELECT '+fieldsToQuery+ ' FROM Placement_Content_Detail__c WHERE Placement_Content__c IN : pContentIds ORDER BY CreatedDate DESC')){
                    if(!contentIdDetailsMap.containsKey(pcDetail.Placement_Content__c)){
                        contentIdDetailsMap.put(pcDetail.Placement_Content__c,new List<Placement_Content_Detail__c>());                           
                    } 
                    contentIdDetailsMap.get(pcDetail.Placement_Content__c).add(pcDetail);
                }
            }
        }
        rWpr.list_PlacLyt = layoutList;
        
        for(Placement_Layout__c eachLayout : layoutList) {
            layoutWpr layoutWprItem = new layoutWpr();
            layoutWprItem.plcLayout = eachLayout;
            list<Placement_Content__c> plcCont_List = new list<Placement_Content__c>();
            List<CDetailsWpr> cdWrpList = new List<CDetailsWpr>();
            for(Placement_Content__c pCnt : eachLayout.Placement_Content__r)
            {
                rWpr.hasContents = true;
                rWpr.pLayoutId = pCnt.Placement_Layout__c;  
                contentWpr cWpr = new contentWpr();
                cWpr.pContentRec = pCnt;
                cWpr.conId = pCnt.Id;
                
                CDetailsWpr cdWpr = new CDetailsWpr();
                cdWpr.pContent = pCnt;
                
                if(contentIdDetailsMap != null && contentIdDetailsMap.containsKey(pCnt.Id)){
                    cdWpr.hasDetails = true;
                    cdWpr.contDetails.addAll(contentIdDetailsMap.get(pCnt.Id));
                }
                cdWrpList.add(cdWpr);
                list_plcContents.add(cWpr);
                plcCont_List.add(pCnt);
            }
            
            layoutWprItem.list_pContent = cdWrpList; 
            list_plcLayouts.add(layoutWprItem);
            rWpr.list_layoutWpr = list_plcLayouts;
            rWpr.list_contentWpr = list_plcContents; system.debug('list_plcContents.....'+list_plcContents);
            
            if(rWpr.list_layoutWpr.isEmpty() || accessMng.Id == Null){
                system.debug('inside---rWpr.list_layoutWpr.isEmpty()---');
                DGTL_ErrorMessages__c errorMessageCustSetting = DGTL_ErrorMessages__c.getValues('DGTL_Main_NoPlaceConts');
                rWpr.errorStatus = errorMessageCustSetting.Error_Message__c;
            }
        }
        resultWprNew placementContentData = rWpr;
        return rWpr;
    }
    
    @AuraEnabled
    public static String getFloorsetName(String floorsetId){
        return DGTL_Util.getFloorsetName(floorsetId);
    }
    
    public class resultWprNew{
        @AuraEnabled public String pLayoutId{get;set;}
        @AuraEnabled public String selectedFloorset {get;set;}
        @AuraEnabled public List<Placement_Layout__c> list_PlacLyt {get;set;}
        @AuraEnabled public String errorStatus{get;set;}
        @AuraEnabled public List<contentWpr> list_contentWpr{get;set;} 
        @AuraEnabled public List<layoutWpr> list_layoutWpr{get;set;}
        @AuraEnabled public Map<String,String> cDetailsReadFieldMap{get;set;}  
        @AuraEnabled public Map<String,String> readFieldsMap {get;set;}
        @AuraEnabled public Boolean hasContents {get;set;}
        @AuraEnabled public date nextDt {get;set;}
        @AuraEnabled public date backDt {get;set;}
        @AuraEnabled public date dateVal {get;set;}
        @AuraEnabled public Decimal timeVal {get;set;}
        @AuraEnabled public String timeValStr {get;set;}
        public resultWprNew(){
            timeValStr = '';
            pLayoutId = '';
            selectedFloorset = '';
            errorStatus = '';
            list_contentWpr = new List<contentWpr>();
            list_layoutWpr = new List<layoutWpr>();
            readFieldsMap = New Map<String,String>();
            hasContents = false;
            nextDt = Null;
            backDt = Null;
            timeVal = Null; 
            list_PlacLyt = NEW List<Placement_Layout__c>();
            Placement_Layout__c obj_placelayout = NEW Placement_Layout__c();
            cDetailsReadFieldMap = new  Map<String,String>();
            list_PlacLyt.add(obj_placelayout);
        }
    }
    
    //Content Wrapper
    public class contentWpr {
        @AuraEnabled public Placement_Layout__c ins_pLayout{get;set;}
        @AuraEnabled public list<Placement_Content__c> list_pContent{get;set;}
        @AuraEnabled Public Placement_Content__c pContentRec{get;set;}
        @AuraEnabled Public Id conId {get;set;}
    }
    
    //Layout Wrapper
    public class layoutWpr {
        @AuraEnabled public List<Placement_Layout__c> list_PlacLyt {get;set;}
        @AuraEnabled public Placement_Layout__c plcLayout{get;set;}
        @AuraEnabled public list<CDetailsWpr> list_pContent{get;set;}
        @AuraEnabled Public Placement_Content__c pContentRec{get;set;}
        @AuraEnabled Public Id conId {get;set;}
    }
    
    public class CDetailsWpr {
        @AuraEnabled public Placement_Content__c pContent{get;set;}
        @AuraEnabled public List<Placement_Content_Detail__c> contDetails {get;set;}
        @AuraEnabled public Boolean hasDetails {get;set;}
        
        public CDetailsWpr(){
            contDetails = new List<Placement_Content_Detail__c>();
            hasDetails = false;
            pContent = new Placement_Content__c() ;
        }
    }
    
    /* Public resultWprNew placementContentData {get; set;}
    Public String fType {get; set;}
    Public String pType {get; set;}
    Public String brand {get; set;}
    Public String dType {get; set;}
    public String loadOnce {get;set;}
    public List<layoutWpr> placementLayout {get;set;}*/
    
   /* public DGTL_ViewPlcLayout_Controller(){
        fType = ApexPages.CurrentPage().getParameters().get('fType');
        pType = ApexPages.CurrentPage().getParameters().get('pType');
        brand = ApexPages.CurrentPage().getParameters().get('brand');
        dType = ApexPages.CurrentPage().getParameters().get('dType');
        dType = ApexPages.CurrentPage().getParameters().get('dType');
        resultWprNew placementContentData = fetchContentNew(brand,pType,null, null,fType,'Search', null,dType);
        system.debug('placementContentData---'+placementContentData);
        //placementLayout = ApexPages.CurrentPage().getParameters().get('placementLayout');
        placementLayout = new List<DGTL_ViewPlcLayout_Controller.layoutWpr>();
    }
    
    public PageReference downloadPDF(){
        fType = ApexPages.CurrentPage().getParameters().get('fType');
        pType = ApexPages.CurrentPage().getParameters().get('pType');
        brand = ApexPages.CurrentPage().getParameters().get('brand');
        dType = ApexPages.CurrentPage().getParameters().get('dType');
        dType = ApexPages.CurrentPage().getParameters().get('dType');
        system.debug('---fType---'+fType+pType+brand+dType);
        placementContentData = fetchContentNew(brand,pType,null, null,fType,'Search', null,dType);
        System.PageReference pageRef = new System.PageReference('/apex/DGTL_ViewPDFGenerator');
       // System.PageReference pageRef = new System.PageReference('/apex/DGTL_ViewPlcLayoutPdfGenerator');
        system.debug('-------DGTL_ViewPDFGenerator2----');
        //ensure pdf downloads and is assigned with defined name
        pageRef.getHeaders().put('content-disposition', 'attachment; filename=Placement-Content.pdf');
        system.debug('-------DGTL_ViewPDFGenerator3----');
        loadOnce = 'false';
        return pageRef;
    }
    
    public static String getLayoutId(id floorset,String pageType) 
    {   String layoutId = '';
        for(Placement_Layout__c lay : [SELECT Id,Name FROM Placement_Layout__c 
                                       WHERE Page_Types__c =: pageType AND Is_Deleted__c = false 
                                       AND Floorset_Plan__c =: floorset  and Type__c='Layout']) 
        {
            layoutId = lay.Id;
        }
        return layoutId;
    }*/
    
    
    
    
    
}