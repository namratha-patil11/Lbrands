/************************************************************
Name          : DGTL_TestDataFactory DONT INSERT ANY DATA IN TEST DATA FACTORY SHOULD CONTAIN ONLY mapping fields
Description   : Test Class to create test data of DGTL objects and used DGTL test classes     
*************************************************************/
@isTest
public class DGTL_TestDataFactory {
    
    public static DGTL_ErrorMessages__c createErrorMessages(string name,string value){
        DGTL_ErrorMessages__c errorMsg = new DGTL_ErrorMessages__c();
        errorMsg.Name = name;
        errorMsg.Error_Message__c = value;
        return errorMsg;
    }
     public static User createUser(Id profileId,string DGTLProfile){       

        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User usr=new User(firstname = 'DGTL', 
                         lastName = 'Test User', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = profileId,
                         DGTL_Profile__c = DGTLProfile
                        ); 
        return usr;
     }
    
    public static PermissionSetAssignment createPermissionSetAssgn(Id userId,Id permissionSetId){
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = permissionSetId;
 		return psa;
    }
    
    public static DGTL_Access_Management__c createAccessManagment(string brand,String objName,String rdFields,String edFields,String pagetype,String tabName,Id RecordTypeId,string DGTLTeam){
         DGTL_Access_Management__c objAM = new DGTL_Access_Management__c();         
        /* for(string fld : fieldValues.keySet()){
             objAM.put(fld,fieldValues.get(fld));
         }*/
         objAM.Brands__c = brand;
         objAM.Page_Type__c = pagetype;
         objAM.Object_Name__c = objName;
         objAM.Read_Only_Fields__c = rdFields;
         objAM.Writable_Fields__c = edFields;         
         objAM.Tab_Name__c = tabName;
        // objAM.UserOrProfile__c = UserOrProfile;
        // objAM.UserOrProfileId__c = UserOrProfileId;
        // objAM.Buttons__c = buttons;
         objAM.Team__c = DGTLTeam;
         objAM.RecordTypeId = RecordTypeId;
         //objAM.Schedule_Interval_Time__c = scheduleInterval;
         return objAM;
     }
     
    public static DGTL_Floorset_Plan__c createFloorsetPlan(string brand,date floordate,string floortime,string floortype){
        DGTL_Floorset_Plan__c floorsetPlan = new DGTL_Floorset_Plan__c();
        floorsetPlan.Brands__c = brand;
        floorsetPlan.Date__c = floordate;
        floorsetPlan.Time__c = floortime;
        floorsetPlan.Type__c = floortype;
 		return floorsetPlan;
    }
     public static Placement_Library__c createPlacementLibrary(Date startdt,Date enddt,string brand,string pagetype,string starttime,string endtime,string device,string status,string offertype,string mainMsg){
         Placement_Library__c pl = new Placement_Library__c();
         pl.Start_Date__c = startdt;
         pl.End_Date__c = enddt;
        // pl.Row_Start__c = rowStart;
        /* for(string fld : fieldValues.keySet()){
             pl.put(fld,fieldValues.get(fld));
         }*/
         pl.Brands__c = brand;
         pl.Page_Types__c = pagetype;
         
         pl.Start_Time__c = starttime;
         pl.End_Time__c = endtime;
         pl.Device_Type__c = device;
         pl.Status__c = status;
         pl.Offer_Type__c = offertype;
        // pl.KOD__c = kodId;
         pl.Main_Message__c = mainMsg;
        /* pl.Placement_type__c = plactype;
         pl.Approver__c = approverId;
         pl.Content_Type__c = contentType;
         pl.Collection_Page_Url__c = collectionPageUrl;
         pl.Grouped__c = 
         pl.Row_Start__c = */
         return pl;
     }
     public static Placement_Layout__c createPlacementLayout(string brand,string pagetype,string device,string floorsetId,string laytype){
         Placement_Layout__c pl = new Placement_Layout__c();
         pl.Brands__c = brand;
         pl.Page_Types__c = pagetype;
         pl.Device_Type__c = device;
         pl.Floorset_Plan__c = floorsetId;
         pl.Type__c = laytype;
         //pl.Is_Deleted__c = isDeleted;
         //pl.Is_Processed__c = isProcessed;
        // pl.Snapshot_Date__c = snapdt;
        /* for(string fld : fieldValues.keySet()){
             pl.put(fld,fieldValues.get(fld));
         } */
         
         //pl.Time__c = tm;
        // pl.Page_Type__c = pagetype;
         //pl.Device_Type__c = device;
         //insert pl;
         return pl;
     }
     
     public static List<Placement_Content__c> createPlacementContentlist(Id plId,String pagetype,Integer sno,string libId,string mainMsg,string contType,string pcType,string plactype,string offertype){
         List<Placement_Content__c> pcList = new List<Placement_Content__c>();
         for(integer i=0; i<sno; i++){
             Placement_Content__c pc = new Placement_Content__c();
             pc.Type__c = pcType;
             pc.Content_Type__c = contType;
             pc.S_No__c = i;
             pc.Placement_Layout__c = plId;
             pc.Page_Name__c = pagetype;
             pc.Approval_Status__c = 'Approved';
             pc.Placement_Library__c = libId;
             pc.Main_Message__c = mainMsg + i;
             pc.Active__c = true;
             pc.Offer_Type__c = offertype;
             pc.Placement_type__c = plactype;
             pcList.add(pc);
         }
        // insert pcList;
         return pcList;
     }
    public static Placement_Content_Detail__c createPlacementContentDetail(string contId,string libId,boolean isDeleted,string slides,string assetPath,string copy){
         Placement_Content_Detail__c objcontDetail = new Placement_Content_Detail__c();
         objcontDetail.Is_Deleted__c = isDeleted;
        objcontDetail.Placement_Content__c = contId;
        objcontDetail.Placement_Library__c = libId;
        objcontDetail.Slides__c = slides;
        objcontDetail.Asset_Path__c = assetPath;
        objcontDetail.Copy__c = copy;
        
        // objcontDetail.Placement_Content__c = contId;
       /* if(string.isNotBlank(selfcontId)){
            objcontDetail.Placement_Content_Detail_Self__c = selfcontId;
        }
        if(string.isNotBlank(libId)){
            objcontDetail.Placement_Library__c = libId;
        }
        if(string.isNotBlank(slides)){
            objcontDetail.Slides__c = slides;
        }
        if(string.isNotBlank(assetPath)){
            objcontDetail.Asset_Path__c = assetPath;
        }
        if(string.isNotBlank(copy)){
            objcontDetail.Copy__c = copy;
        } */
         
		return objcontDetail;         
     }
    
    public static Placement_Content_Detail_History__c createContentDetailHistory(id contDetailId){
        Placement_Content_Detail_History__c detailHistory = new Placement_Content_Detail_History__c();
        detailHistory.Placement_Content_Detail__c = contDetailId;
        return detailHistory; 
    }
    
    public static Placement_Content_History__c createContentHistory(id contId){
        Placement_Content_History__c detailHistory = new Placement_Content_History__c();
        detailHistory.Placement_Content__c = contId;
        return detailHistory; 
    }
    
    public static Placement_Content_Detail__c createPlacementContentDetail(id contId){
        Placement_Content_Detail__c placementDetail = new Placement_Content_Detail__c();
        placementDetail.Placement_Content__c = contId;
        placementDetail.Link_Text__c = 'some Link Text';
        placementDetail.Copy__c = 'Copy Text';
        placementDetail.Slides__c = 'Slide 1';
        placementDetail.Sub_Type__c = 'Video';
        placementDetail.Asset_Path__c = 'Asset Path Text';
        return placementDetail;
    }
    
    public static DGTL_Task__c createEscalationTask(ID contentId){
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('Escalation').getRecordTypeId();
        DGTL_Task__c digitalTask = new DGTL_Task__c();
        digitalTask.RecordTypeId = TaskRecordTypeId;
        digitalTask.Parent_Content__c = contentId;
        digitalTask.Status__c = 'New';
        return digitalTask;
    }
    
    public static Placement_Content__c createPlacementContent(ID layoutId, Id libId){
        
        Placement_Content__c content = new Placement_Content__c();
        content.Type__c = 'Controlled';
        content.Content_Type__c = 'Video';
        content.S_No__c = 2;
        content.Placement_Layout__c = layoutId;
        content.Page_Name__c = 'Home Page';
        content.Approval_Status__c = 'Approved';
        content.Placement_Library__c = libId;
        content.Main_Message__c =  'Main Message';
        content.Active__c = true;
        content.Offer_Type__c = 'Offer';
        content.Placement_type__c = 'Feature';
        
        return content;
    }
    
    public static Placement_Content__c createEscalationPlacementContent(ID layoutId, Id libId){
        
        Placement_Content__c content = new Placement_Content__c();
        content.Type__c = 'Escalation';
        content.Content_Type__c = 'Video';
        content.S_No__c = 2;
        content.Placement_Layout__c = layoutId;
        content.Page_Name__c = 'Home Page';
        content.Approval_Status__c = 'Approved';
        content.Placement_Library__c = libId;
        content.Main_Message__c =  'Main Message';
        content.Active__c = true;
        content.Offer_Type__c = 'Offer';
        content.Placement_type__c = 'Feature';
        
        return content;
    }
    
    public static DGTL_Task__c createOnchangeTaskContent(String team, Id ContentId){
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        DGTL_Task__c digitalTask = new DGTL_Task__c();
        digitalTask.RecordTypeId = TaskRecordTypeId;
        digitalTask.Description__c = 'Copy__c';
        digitalTask.Status__c = 'New';
        digitalTask.DGTL_TaskOwner__c = team;
        digitalTask.Placement_Content__c = ContentId;
        digitalTask.Type__c = 'Automatic';
        digitalTask.Object_Type__c ='Placement Content';
        return digitalTask;
    }
    public static DGTL_Task__c createOnchangeTaskContentDet(String team, Id ContentId){
        Id TaskRecordTypeId = Schema.SObjectType.DGTL_Task__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        DGTL_Task__c digitalTask = new DGTL_Task__c();
        digitalTask.RecordTypeId = TaskRecordTypeId;
        digitalTask.Description__c = 'Copy__c';
        digitalTask.Status__c = 'New';
        digitalTask.DGTL_TaskOwner__c = team;
        digitalTask.Placement_Content__c = ContentId;
        digitalTask.Type__c = 'Automatic';
        digitalTask.Object_Type__c ='Placement Content Detail';
        return digitalTask;
    }
    
     public static DGTL_Access_Management__c createScheduleRecords(string brand,Id RecordTypeId,string DGTLTeam){
         DGTL_Access_Management__c objAM = new DGTL_Access_Management__c();  
         objAM.Brands__c = brand;
         objAM.Team__c = DGTLTeam;
         objAM.RecordTypeId = RecordTypeId;
         objAM.Schedule_Interval_Time__c = '30 mins';
         
         return objAM;
     }
    
    public static DGTL_Access_Management__c createScheduleRecordsInHours(string brand,Id RecordTypeId,string DGTLTeam){
         DGTL_Access_Management__c objAM = new DGTL_Access_Management__c();  
         objAM.Brands__c = brand;
         objAM.Team__c = DGTLTeam;
         objAM.RecordTypeId = RecordTypeId;
         objAM.Schedule_Interval_Time__c = '2 hrs';
         
         return objAM;
     }

    public static History_Tracking__c createOnChangeHisRec(string brand,string DGTLTeam, String category,Id pContentId,Id layoutId ){
        Id recordTypeId = Schema.SObjectType.History_Tracking__c.getRecordTypeInfosByName().get('OnChange').getRecordTypeId();
        History_Tracking__c hisRec = New History_Tracking__c();
        hisRec.Placement_Content__c = pContentId;
        hisRec.Brand__c = brand;
        hisRec.Owner__c = DGTLTeam;
        hisRec.Category__c = category;
        hisRec.Placement_Layout__c = layoutId;
        hisRec.recordTypeId = recordTypeId;
        hisRec.Object_Name__c = 'Placement Content';
        return hisRec;
    }
    
    public static DGTL_Access_Management__c createAccessManagmentWithCategory(string brand,String objName,String rdFields,String category,string DGTLTeam,string chatterGrp  ){
        DGTL_Access_Management__c objAM = new DGTL_Access_Management__c();   
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        objAM.Brands__c = brand;
        objAM.Object_Name__c = objName;
        objAM.Read_Only_Fields__c = rdFields;
        objAM.Team__c = DGTLTeam;
        objAM.Category__c = category;
        objAM.Schedule_Interval_Time__c = '30 mins';
        objAM.RecordTypeId = RecordTypeId;
        objAM.Chatter_Subscribed_Group__c = chatterGrp;
        return objAM;
    }
    
    public static DGTL_Access_Management__c createAccessManagmentWithCategory1(string brand,String objName,String rdFields,String category,string DGTLTeam ,string chatterGrp){
        DGTL_Access_Management__c objAM = new DGTL_Access_Management__c();   
        Id RecordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        objAM.Brands__c = brand;
        objAM.Object_Name__c = objName;
        objAM.Read_Only_Fields__c = rdFields;
        objAM.Team__c = DGTLTeam;
        objAM.Category__c = category;
        objAM.Schedule_Interval_Time__c = '2 hrs';
        objAM.RecordTypeId = RecordTypeId;
        objAM.Chatter_Subscribed_Group__c = chatterGrp;
        return objAM;
    }
    
    Public static Digital_Live_Users__c createLiveUser(Id layoutId,Datetime lastPollDate)
    {
        Digital_Live_Users__c liveUser = new Digital_Live_Users__c();
        liveUser.Tab_Name__c='DGTL Main';
        liveUser.Layout__c = layoutId;
        liveUser.Last_Poll_Time__c = lastPollDate;
        return liveUser;
        
    }
    
}