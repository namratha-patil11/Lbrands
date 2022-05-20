/*
 * Name 	   : DGTL_WrapperClasses
 * Description : This class contains wrapper classes for digital applicaiton  
 * 
 */
public class DGTL_WrapperClasses {
    
    
    /*
     * Name 	   : LayoutSearchWrp
     * Description : This class contains list of variables, which is returned on digital layout search   
     * 
     */
    public class LayoutSearchResults
    {
        @AuraEnabled public Placement_Layout__c plaLayout{get;set;}
        @AuraEnabled public String pLayoutId{get;set;}
        @AuraEnabled public String pLibraryId{get;set;}
        @AuraEnabled public String selectedFloorset {get;set;}
        @AuraEnabled public List<Placement_Layout__c> list_PlacLytFloorset {get;set;}
        @AuraEnabled public String errorStatus{get;set;}
        @AuraEnabled public String errorCode{get;set;}
        @AuraEnabled public List<contentWprNew> list_contentWpr{get;set;}
        @AuraEnabled public Map<String,String> readFieldsMap {get;set;}
        @AuraEnabled public Map<String,String> editFieldsMap {get;set;}
        @AuraEnabled public Map<String,String> detailReadFieldsMap {get;set;}
        @AuraEnabled public Map<String,String> detailWriteFieldsMap {get;set;}
        @AuraEnabled public Map<String, String> miniViewFieldsMap{get;set;}
        @AuraEnabled public String buttons {get;set;}
        @AuraEnabled public Boolean isEditable {get;set;}
        @AuraEnabled public Boolean hasContents {get;set;}
        @AuraEnabled public date nextDt {get;set;}
        @AuraEnabled public date backDt {get;set;}
        @AuraEnabled public date dateVal {get;set;}
        @AuraEnabled public Decimal timeVal {get;set;}
        @AuraEnabled public String timeValStr {get;set;}
        @AuraEnabled public String unsavedContAlert {get;set;}
        @AuraEnabled public String userDefaultBrand {get;set;}
        @AuraEnabled public Map<String,String> transactionMessageMap {get;set;}
        @AuraEnabled public Boolean layoutHasComments {get;set;}
        @AuraEnabled public Map<string,Integer> ContentTypesBtns{get;set;}
        @AuraEnabled public Boolean isPreviousLayout {get;set;}
        public LayoutSearchResults()
        {
            timeValStr = '';
            unsavedContAlert = '';
            pLayoutId = '';
            pLibraryId = '';
            selectedFloorset = '';
            buttons = '';
            errorCode = '';
            errorStatus = '';
            list_contentWpr = new List<contentWprNew>();
            readFieldsMap = New Map<String,String>();
            editFieldsMap = New Map<String,String>();
            detailReadFieldsMap = new Map<String,String>();
        	detailWriteFieldsMap = new Map<String,String>();
            miniViewFieldsMap = new Map<String,String>();
            transactionMessageMap = new Map<String,String>();
            isEditable = false ; 
            hasContents = false;            
            nextDt = Null;
            backDt = Null;
            timeVal = Null; 
            list_PlacLytFloorset = NEW List<Placement_Layout__c>();
            Placement_Layout__c obj_placelayout = NEW Placement_Layout__c();
            list_PlacLytFloorset.add(obj_placelayout);
            userDefaultBrand = '';
            layoutHasComments = false;
            ContentTypesBtns = new Map<string,Integer>();
            isPreviousLayout = false;
            
        }
    }
    
    public class KODDetail{
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public String id{get;set;}
        
    }
    
    public class contentWprNew
    {
        @AuraEnabled public String conId{get;set;}
        @AuraEnabled public String errorStatus {get;set;}
        @AuraEnabled public Placement_Content__c pContentRec{get;set;}
        @AuraEnabled public List<String> detailAllFeildList {get;set;}
        @AuraEnabled public ContentDetailWrp ContentDetWpr{get;set;}
        @AuraEnabled public  List<KODDetail> kodList{get;set;}
        @AuraEnabled public  Boolean hasNewComments{get;set;}
        @AuraEnabled public  Boolean cascade{get;set;}
        @AuraEnabled public  Boolean removeBtn{get;set;}
        @AuraEnabled public  Boolean commentBtn{get;set;}
        @AuraEnabled public  Boolean historyBtn{get;set;}
        @AuraEnabled public  Boolean updateContent{get;set;}
        @AuraEnabled public  Boolean abTestBtn{get;set;}
        @AuraEnabled public  Boolean TakedownBtns{get;set;}
        @AuraEnabled public  Boolean addKOD{get;set;}
        @AuraEnabled public  Boolean enableContentTypePrompt{get;set;}
        @AuraEnabled public  List<String> ContentTypesList{get;set;}
        @AuraEnabled public  Boolean createTicketBtn{get;set;}
        @AuraEnabled public String clonedContId{get;set;}

        public contentWprNew()
        {
            conId = '';
            clonedContId = '';
            pContentRec = new Placement_Content__c();
            
            detailAllFeildList = new List<String>();
            ContentDetWpr = New ContentDetailWrp();
            kodList = new List<KODDetail>();
            hasNewComments = false;
            cascade = false;
            removeBtn = false;
            commentBtn = false;
            historyBtn = false;
            updateContent = false;
            abTestBtn = false;
            TakedownBtns = false;
            addKOD = false;
            enableContentTypePrompt = false;
            ContentTypesList = new list<string>();
            createTicketBtn = false;
        }
    }
    
        

	 /*
     * Name 	   : ContentDetailWrp
     * Description : This class contains list of variables for storing content Details in Layout Tab
     */    
     public class ContentDetailWrp
    {
        @AuraEnabled public String errorStatus{get;set;}
        @AuraEnabled public Boolean hasContents {get;set;}
        @AuraEnabled public Boolean isCarousel {get;set;}
        @AuraEnabled public list<Placement_Content_Detail__c> detailList {get;set;}
        @AuraEnabled public list<Placement_Content_Detail__c> detailDeleteList {get;set;}
        
        public ContentDetailWrp()
        {
            errorStatus = '';
            hasContents = false;
            isCarousel = false;
            detailList = New list<Placement_Content_Detail__c>();
            detailDeleteList = New list<Placement_Content_Detail__c>();
        }
    }
    
    public class FollowDetails{
        @AuraEnabled public Boolean isFeedEnabled;
        @AuraEnabled public Boolean isFollowed;
        
        public FollowDetails(){
            isFeedEnabled = false;
            isFollowed = false;
        }
    }
    
    public class UserComparePreferences{
        @AuraEnabled public Boolean hasUserPreference;
        @AuraEnabled public DGTL_Access_Management__c accMgt;
        @AuraEnabled public List<String> selectedOptions;
        @AuraEnabled public List<DGTL_ComparePlcLayout_Ctr.SelectOption> options;
        
    }
    

}