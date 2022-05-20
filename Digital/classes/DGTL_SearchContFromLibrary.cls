/*****
 * Name         : DGTL_SearchContFromLibrary
 * Description  : This Class is used to create contents from library and to display in table
 * Author       : Vidya Sagar 
 * Component    : This class is controller for lightning compoenent DGTL_SearchContInLibrary.cmp
****/
public class DGTL_SearchContFromLibrary {
    
    /*
	*   Description : This Method is used to add search/filter with input fields(brand,page type,main message) from library 
	*	Component helper method : searchContentToHpr
    *   return : list of layout with size 1
	*/
    @AuraEnabled
    public static List<Placement_Library__c> fetchFilterValues()
    {
        Placement_Library__c obj = new Placement_Library__c();
		List<Placement_Library__c> list_LibraryearchFilter = new List<Placement_Library__c>{obj};
        return list_LibraryearchFilter;
    }
    
    /*
	*   Description             :This Method is used to get list of library, when user clicks on search button
	*	Component helper method : fetchLibraryJsHpr
	*   Param                   : lib_search - library object with brand,page type,main message and editorial name to search 
	*   return                  : return list of library 
	*/
    @AuraEnabled(cacheable=true)
    public static list<Placement_Library__c> fetchLibrary(Placement_Library__c lib_search)
    {
               
        List<Placement_Library__c> list_Library = new List<Placement_Library__c>();
        Placement_Library__c obj_libFields = new Placement_Library__c();
        // checks for Editorials page type
        if(lib_search.Page_Types__c == 'Editorials'){ 
            String libraryQuery = DGTL_DataAccessor.getSobjectSoql(new Placement_Library__c());
            libraryQuery += ' AND Brands__c =\''+lib_search.Brands__c+'\' AND Page_Types__c =\''+lib_search.Page_Types__c+'\''  ; 
            // checks for main message
            if(string.isNotBlank(lib_search.Main_Message__c)) libraryQuery += ' AND Main_Message__c like \'%'+lib_search.Main_Message__c+'%\'' ;
            //checks for editorial name
            if(string.isNotBlank(lib_search.Editorial_Name__c)){
               libraryQuery += ' AND Editorial_Name__c like \'%'+lib_search.Editorial_Name__c+'%\' Order by Position__c';
            }
            list_Library = Database.query(libraryQuery); system.debug('libraryQuery--'+libraryQuery);
        } else{
            list_Library = DGTL_DataAccessor.getLibraryList(DGTL_DataAccessor.getSobjectSoql(obj_libFields), lib_search.Brands__c, lib_search.Page_Types__c, lib_search.Start_Date__c, null, null,null,lib_search.Main_Message__c);       
        }
        return list_Library;
    }
    /*
	*   Description             : This Method is used to Create contents from selectded library, when user clicks on Add Contents
	*	Component helper method : addContsHpr
	*   Param                   : lst_SelectedContIds - selectded libraries ids to create content, pLayoutId - palacement layout id 
	*   Return                  : returns list of DGTL_WrapperClasses.contentWprNew
	*/
    @AuraEnabled
    public static list<DGTL_WrapperClasses.contentWprNew> getSelectedConts(List<string> lst_SelectedContIds,string pLayoutId)
    {
        try{
            list<DGTL_WrapperClasses.contentWprNew> list_cWpr = new list<DGTL_WrapperClasses.contentWprNew>();
        List<Placement_Library__c> list_library = new List<Placement_Library__c>();
        list<Placement_Content__c> list_Contents = new list<Placement_Content__c>();
        Placement_Content_Detail__c obj_Cont_Detail = new Placement_Content_Detail__c();
        list<Placement_Content_Detail__c> list_ContDetail = new list<Placement_Content_Detail__c>();
        list<Placement_Content_Detail__c> list_ContDetailCloned = new list<Placement_Content_Detail__c>();
        string contDetail_soql = DGTL_DataAccessor.getSobjectSoql(obj_Cont_Detail);
        Placement_Library__c obj_Lib = new Placement_Library__c();        
        string lib_soql = DGTL_DataAccessor.getSobjectSoql(obj_Lib);
        lib_soql += ' AND Id In : lst_SelectedContIds';
        // fetch selected libraries
        list_library = Database.query(lib_soql); 
        // creatining content from selected libraries
        list_Contents = DGTL_DataAccessor.createContentsFromLibrary(list_library, DGTL_DataAccessor.getLibraryCopyFieldset());
        for(Placement_Content__c cont :list_Contents)
        {
            cont.Placement_Layout__c = pLayoutId;
            cont.Name='Test';
            system.debug('---pLayoutId--'+cont.Placement_Layout__c);
        }
        // inserting contents 
        insert list_Contents; 
        string cont_soql = DGTL_DataAccessor.getSobjectSoql(new Placement_Content__c()) + ' AND Id In:list_Contents';
        // cloning content details
         contDetail_soql +=  ' AND Placement_Library__c In : lst_SelectedContIds';
         list_ContDetail = Database.query(contDetail_soql);
        for(Placement_Content_Detail__c details : list_ContDetail){
               Placement_Content_Detail__c newDetail = new Placement_Content_Detail__c();
               newDetail = details.clone(false, false, false, false);
               list_ContDetailCloned.add(newDetail);
            }
        for(Placement_Content__c cont : Database.query(cont_soql))
        {
            DGTL_WrapperClasses.contentWprNew cWpr = new DGTL_WrapperClasses.contentWprNew();
            cWpr.pContentRec = cont;
            cWpr.conId = cont.Id; 
            cWpr.errorStatus = 'Success';
            list_cWpr.add(cWpr);
            for(Placement_Content_Detail__c details :list_ContDetailCloned){
                if(details.Placement_Library__c != null && details.Placement_Library__c == cont.Placement_Library__c)
                {
                    details.Placement_Library__c = null;
                    details.Placement_Content__c = cont.Id;
                }
            }
        }
        // creating content details
        if(!list_ContDetailCloned.isEmpty())
        {
            insert list_ContDetailCloned;
            system.debug('-list_ContDetailCloned--'+list_ContDetailCloned);
        }
       return list_cWpr;
        }catch(Exception ex){
            system.debug('---'+ex.getMessage());
            return null;
        }
        
    }

}