/*****
 * Name         : DGTL_Main_AddToLibrary
 * Description  : This Class is used to create library and content 
 * Author       : Vidya Sagar 
 * Component    : This class is controller for lightning compoenent DGTL_Main_AddToLibrary.cmp
****/
public class DGTL_Main_AddToLibrary {

     /*
      *   Description : This Method is used to get fiedl set of library
      *   Return      : list, fields of library
      */
    @AuraEnabled
    public static List<String> fetchlibFields()
    {        
        fetchFilterValuesWrp rWpr = new fetchFilterValuesWrp();
        rWpr.list_libraryFieldSet = DGTL_DataAccessor.getAddLibraryFieldset();
        return DGTL_DataAccessor.getAddLibraryFieldset();
    }
    
    /*
      *   Description : This Method is used to Create new Placement_Content__c
      *   Param       : placLibrId -  Placement_Library__c id, pLayoutId - Placement_Layout__c id
      *   Return      : list, DGTL_WrapperClasses.contentWprNew 
      */
     @AuraEnabled
    public static list<DGTL_WrapperClasses.contentWprNew> createLibAndContent(String placLibrId,String pLayoutId)
    {
        list<DGTL_WrapperClasses.contentWprNew> list_cWpr = new list<DGTL_WrapperClasses.contentWprNew>();
        DGTL_WrapperClasses.contentWprNew cWpr = new DGTL_WrapperClasses.contentWprNew();
        try{
            // get library fields
            list<Placement_Library__c> list_Library = new list<Placement_Library__c>();
        	Placement_Library__c obj_lib = new Placement_Library__c();
            list_Library = DGTL_DataAccessor.getLibraryList(DGTL_DataAccessor.getSobjectSoql(obj_lib), null, null, null, 'Position__c', null,placLibrId,'');

            list<Placement_Content__c> list_Contents = new list<Placement_Content__c>();
            // creating content from library
            list_Contents = DGTL_DataAccessor.createContentsFromLibrary(list_Library, DGTL_DataAccessor.getLibraryCopyFieldset());
            list_Contents[0].Placement_Library__c = placLibrId;
        	list_Contents[0].Placement_Layout__c = pLayoutId;
            list_Contents[0].Type__c = 'Controlled';
            // inserting contents
            insert list_Contents;            
			Id contId = list_Contents[0].Id;  
			Placement_Content__c obj_NewCont = new Placement_Content__c();
            string soql_cont = DGTL_DataAccessor.getSobjectSoql(obj_NewCont) + ' AND Id=:contId';
            obj_NewCont = list_Contents[0];
            list_Contents = new list<Placement_Content__c>();
            list_Contents = Database.query(soql_cont);
            // assigning list of contents to wrapper class                
            cWpr.pContentRec = list_Contents[0];
            cWpr.conId = string.valueof(list_Contents[0].Id);
            cWpr.errorStatus = 'Success';
            list_cWpr.add(cWpr);
            return list_cWpr;
        }catch(exception e)
        {
            delete [select Id from Placement_Library__c where id=:placLibrId];
            cWpr.errorStatus = e.getMessage();
            list_cWpr.add(cWpr);
            return list_cWpr;
        } 
    }
     public class fetchFilterValuesWrp
     {
          @AuraEnabled public List<Placement_Library__c> list_Library {get;set;}
          @AuraEnabled public List<String> list_libraryFieldSet {get;set;}
          @AuraEnabled public List<String> list_ContFieldSet{get;set;}
          public fetchFilterValuesWrp()
         {
             list_Library = NEW List<Placement_Library__c>();
             Placement_Library__c obj = new Placement_Library__c();
             list_Library.add(obj);
             list_libraryFieldSet = NEW List<String>();
             list_ContFieldSet = NEW List<String>();
         }
     }
}