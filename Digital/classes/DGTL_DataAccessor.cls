/*
 * Name 	   : DGTL_DataAccessor
 * Description : This class is used as utility class for digital applicaiton classes 
 * Author      : Vidya Sagar
 */
public class DGTL_DataAccessor {

    /*
 	* Name 	      : getAccessMang
	* Description : This method is used to get access management record of current logged in user
	* param       : selectedBrand - selected brand(VS/PINK/Beauty,SWIM), pageType - selected page type(home page/landing page etc)
	* param       : objName - object name picklist value, tabName - tab name
 	* return      : returns access management record    
 	*/
    public static DGTL_Access_Management__c getAccessMang(string selectedBrand,String pageType,String objName,string tabName,Id recordTypeId)
    {
        User userRec = new User();
        userRec = [SELECT id, name , DGTL_Profile__c from User where id =: UserInfo.getUserId() LIMIT 1];
        DGTL_Access_Management__c obj_AccessMang = new DGTL_Access_Management__c();
        for(DGTL_Access_Management__c AM : [select id,Object_Name__c, Page_Type__c,Read_Only_Fields__c,UserOrProfile__c,
                                           UserOrProfileId__c,Writable_Fields__c,MiniView_RO_Fields__c,Team__c,Buttons__c,Tab_Name__c,Brands__c,Button__c
                                           from DGTL_Access_Management__c
                                           where  Object_Name__c = :objName  and Tab_Name__c = :tabName and
                                           (UserOrProfileId__c=:UserInfo.getUserId() or UserOrProfileId__c=:UserInfo.getProfileId() 
                                           or Team__c =: userRec.DGTL_Profile__c) and
                                           (Page_Type__c = :pageType or Page_Type__c = Null) 
                                           and Brands__c=:selectedBrand and recordTypeId =:recordTypeId
                                           order by UserOrProfileId__c desc, Page_Type__c desc limit 1])
        {
            if(AM.UserOrProfileId__c == UserInfo.getUserId()){
                obj_AccessMang = AM;
                break;                
            }
            else if(AM.UserOrProfileId__c == UserInfo.getProfileId())  obj_AccessMang = AM;
            else if(AM.Team__c == userRec.DGTL_Profile__c) obj_AccessMang = AM;
        }
        
        return obj_AccessMang;
        
    }
    
    
    /*
 	* Name 	      : getFloorsetPlanList
	* Description : This method is used to get list of floorset plans
	* param       : floorsetPlanId - floorset plan record id,searchNextBack - search key word(search/Next Update/Next Update)
    * param       : dateVal - selected date to search   
 	* return      : returns list of floorset plans
 	*/
    public static List<DGTL_Floorset_Plan__c> getFloorsetPlanList(string strSoql,string floorsetId,string searchNextBack,date dateVal)
    {        
        List<DGTL_Floorset_Plan__c> list_Floorset = new List<DGTL_Floorset_Plan__c>();
        //String floorsetSoql = 'SELECT Id,Name,Date__c,Time__c,Time_No__c,Brands__c FROM DGTL_Floorset_Plan__c WHERE ;//Id=:floorsetPlanId ';
      
        if(searchNextBack=='Search'){
            strSoql += ' AND Id=: floorsetId' ;
        }
        else if(searchNextBack=='Next Update'){
            strSoql += ' AND Id !=: floorsetId AND Date__c >=:dateVal order by Date__c,Time_No__c limit 25' ;
        }
        else if(searchNextBack=='Previous Update'){
            strSoql += ' AND Id !=: floorsetId AND Date__c <=:dateVal order by Date__c desc,Time_No__c desc limit 25' ;
        }
        list_Floorset = Database.query(strSoql);
        return list_Floorset;
        
    }
    
    /*
 	* Name 	      : getFloorsetPlanList1
	* Description : This method is used to get list of floorset plans
	* param       : layout - Placement_Layout__c,searchNextBack - search key word(search/Next Update/Next Update), strSoql - string soql
    * param       : dateVal - selected date to search   
 	* return      : returns list of floorset plans
 	*/
     public static List<DGTL_Floorset_Plan__c> getFloorsetPlanList1(string strSoql,Placement_Layout__c layout,string searchNextBack,date dateVal)
     {       
         List<DGTL_Floorset_Plan__c> list_Floorset = new List<DGTL_Floorset_Plan__c>();        
         if(layout!= null) {
             id fId = layout.Floorset_Plan__c;string brand = layout.Brands__c;
         }
         if(searchNextBack=='Search'){
             strSoql += ' AND Id=: fId' ;
         }
         else if(searchNextBack=='Next Update'){
             strSoql += ' AND Id !=: fId AND Brands__c =: brand AND Date__c >=:dateVal order by Date__c,Time_No__c limit 25' ;
         }
         else if(searchNextBack=='Previous Update'){
             strSoql += ' AND Id !=: fId AND Brands__c =: brand AND Date__c <=:dateVal order by Date__c desc,Time_No__c desc limit 25' ;
         }
         list_Floorset = Database.query(strSoql);
         return list_Floorset;        
    }
    
    /*
 	* Name 	      : getValidFloorset
	* Description : This method is used to get next/previous floorset plan
	* param       : list_floorset - list of floorset plan,searchNextBack - search key word(search/Next Update/Next Update)
    * param       : dateVal - selected date to search, timeVal - selected time value to search
 	* return      : returns floorset plan record 
 	*/
    public static DGTL_Floorset_Plan__c getValidFloorset(List<DGTL_Floorset_Plan__c> list_floorset,string searchNextBack,date dateVal,decimal timeVal)
    {   
        DGTL_Floorset_Plan__c obj_FloorSetPlan = new DGTL_Floorset_Plan__c();
       for(DGTL_Floorset_Plan__c flr : list_floorset)
       {
           // checks for next upate/next date
           if(searchNextBack=='Next Update'){
               if(flr.Date__c == dateVal && flr.Time_No__c > timeVal)
                {
                    obj_FloorSetPlan = flr;
                    break;
                }else if(flr.Date__c > dateVal){
                    obj_FloorSetPlan = flr;
                    break;
                }                
           }
           // checks for Previous upate/Previous date
           else if(searchNextBack=='Previous Update'){
               if(flr.Date__c == dateVal && flr.Time_No__c < timeVal)
                {
                    obj_FloorSetPlan = flr;
                    break;
                }else if(flr.Date__c < dateVal){
                    obj_FloorSetPlan = flr;
                    break;
                }                
           }
       }
        system.debug(obj_FloorSetPlan);
        return obj_FloorSetPlan;
    }
    
    /*
 	* Name 	      : getLibraryList
	* Description : This method is used to get library list
	* param       : selectedBrand - selected brand(VS/PINK/Beauty,SWIM), pageType - selected page type(home page/landing page etc)
	* param       : dateVal - selected date to search
 	* return      : returns list of librarys    
 	*/
    public static List<Placement_Library__c> getLibraryList(string strSoql,string selectedBrand,string pageType, date dateVal,string orderby,string ascdesc,string libId,string mainMsg)
    {        
        List<Placement_Library__c> list_Library = new List<Placement_Library__c>();
        if(string.isNotBlank(libId)){
            strSoql += ' AND Id=:libId' ;
        }        
        if(string.isNotBlank(mainMsg)){
            mainMsg = '\'%' + mainMsg + '%\'';
            strSoql += ' AND Main_Message__c like '+mainMsg ;
        }
        if(string.isNotBlank(selectedBrand)){
            strSoql += ' AND Brands__c=:selectedBrand' ;
        }
        if(string.isNotBlank(pageType)){
             strSoql += ' AND Page_Types__c =: pageType';
        }
        if(dateVal != null){
             strSoql += ' AND End_Date__c >=: dateVal AND Start_Date__c <=: dateVal';
        }        
        if(string.isNotBlank(orderby)){
            strSoql += ' order by Position__c' ;
        }
        if(string.isNotBlank(ascdesc) && ascdesc=='desc'){
            strSoql += ' desc' ;
        }
        list_Library = Database.query(strSoql);
        return list_Library;
    }
    
    /*
 	* Name 	      : getValidLibraryList
	* Description : This method is used to get library list
	* param       : list_Library - list of library, timeVal - selected time value to search
	* param       : dateVal - selected date to search
 	* return      : returns list of librarys    
 	*/
    public static List<Placement_Library__c> getValidLibraryList(List<Placement_Library__c> list_Library,date dateVal,decimal timeVal)
    {        
        List<Placement_Library__c> list_LibraryTime = New List<Placement_Library__c>();
        for(Placement_Library__c lib : list_Library) 
        {
           // boolean used to filter for date and time between start/end date 
           boolean validLibrary = false;
           if(lib.Start_Date__c < dateVal && lib.End_Date__c > dateVal){
                    validLibrary = true;
             }else if(lib.Start_Date__c == dateVal && lib.Start_Time_No__c <= timeVal){
                    validLibrary = true;
             }else if(lib.End_Date__c == dateVal && lib.End_Time_No__c >= timeVal){
                    validLibrary = true;
             } 
            if(validLibrary){
                list_LibraryTime.add(lib);
            }
        }
        
        return list_LibraryTime;
        
    } 
    
    
    /*
 	* Name 	      : getLayoutList
	* Description : This method is used to get list of layouts
	* param       : selectedBrand - selected brand(VS/PINK/Beauty/SWIM), pageType - selected page type(home page/landing page etc)
	* param       : dateVal - selected date to search,timeVal - selected time value to search,layType - selected layout type
 	* return      : returns list of placement content history    
 	*/
    public static List<Placement_Layout__c> getLayoutList(string strSoql,string selectedBrand,string pageType, date dateVal,decimal timeVal,string layType,string layId,string deviceType,Id floorsetId)
    {
        List<Placement_Layout__c> list_layout = new List<Placement_Layout__c>();
        if(String.isNotEmpty(layId)){
            strSoql += ' AND Id =:layId';
        }
        if(String.isNotEmpty(deviceType)){
            strSoql += ' AND Device_Type__c =:deviceType';
        }
        if(String.isNotEmpty(floorsetId)){
            strSoql += ' AND Floorset_Plan__c =:floorsetId';
        }
        if(String.isNotEmpty(selectedBrand)){
            strSoql += ' AND Brands__c =:selectedBrand';
        }
        if(String.isNotEmpty(pageType)){
            strSoql += ' AND Page_Types__c=:pageType';
        }
        if(String.isNotEmpty(layType)){
            strSoql += ' AND Type__c=:layType';
        }
        if(dateVal != null){
            strSoql += ' AND Date__c=:dateVal';
        }
        if(timeVal != null){
            strSoql += ' AND Time_No__c=:timeVal';
        }     
        strSoql += ' AND Is_Deleted__c = false ';
        list_layout = Database.query(strSoql);
        return list_layout;
    }
    
    /*
 	* Name 	      : getContentList
	* Description : This method is used to get list of placement content  
	* param       : layId - placement content layout id,orderby - order by field,ascdesc - asc or desc
 	* return      : returns list of placement content    
 	*/
    public static List<Placement_Content__c> getContentList(string strSoql,String layId,string orderby,string ascdesc,list<string> libIds,string limitcount,boolean isActive)
    {  
        
        List<Placement_Content__c> list_Contents = new List<Placement_Content__c>();         
        if(String.isNotEmpty(layId)){
            strSoql += ' AND Placement_Layout__c=:layId';
        }
        if(libIds !=null && !libIds.isEmpty()){
            strSoql += ' AND Placement_Library__c IN :libIds'; 
        }
        if(isActive){
            strSoql += ' AND Active__c=:isActive';
        }
        if(String.isNotEmpty(orderby)){
            strSoql += ' order by '+orderby;
        }
        if(String.isNotEmpty(ascdesc) && ascdesc == 'desc'){
            strSoql += ' desc';
        }
        if(String.isNotEmpty(limitcount)){
            strSoql += ' limit '+limitcount;
        }system.debug(strSoql);
        list_Contents = Database.query(strSoql);
        return list_Contents;
       
    }
    
    /*
 	* Name 	      : createContentsFromLibrary
	* Description : This method is used to get to create list of contents from library  
	* param       : list_Library - list of searched library to create contents,list_ContFields - list of Content fields(Api Names)
 	* return      : returns list of placement content    
 	*/
    public static List<Placement_Content__c> createContentsFromLibrary(List<Placement_Library__c> list_Library,List<String> list_ContFields)
    {
        List<Placement_Content__c> list_Contents = new List<Placement_Content__c>();
        for(Placement_Library__c lib : list_Library)
        {         
            Placement_Content__c new_Cont = new Placement_Content__c();
            for(String fld : list_ContFields)
            {
                new_Cont.put(fld,lib.get(fld));
            }
            new_Cont.Placement_Library__c = lib.Id; 
            new_Cont.Image__c = lib.Image__c;
            new_Cont.Type__c = 'Controlled';
            new_Cont.Active__c = true;
            list_Contents.add(new_Cont);
        }
        
        return list_Contents;
    }
    
    /*
 	* Name 	      : getContentHistory
	* Description : This method is used to get history of placement content record 
	* param       : pConId - placement content record id
 	* return      : returns list of placement content history    
 	*/
   /* public static List<Placement_Content_History__c> getContentHistory(string strSoql,String pConId,string orderby,string ascdesc)
    {
        List<Placement_Content_History__c> list_ContHistory = new List<Placement_Content_History__c>();
        if(String.isNotEmpty(pConId)){
            strSoql += ' AND Placement_Content__c=:pConId';
        }
        if(String.isNotEmpty(orderby)){
            strSoql += ' order by CreatedDate';
        }
        if(String.isNotEmpty(ascdesc) && ascdesc == 'desc'){
            strSoql += ' desc';
        }
        list_ContHistory = Database.query(strSoql);
        return list_ContHistory;
       
    } */
    
    /*
 	* Name 	      : getLibraryCopyFieldset
	* Description : This method is used to get fieldset(placement content fields) from libarary object
 	* return      : returns list of fields api names
 	*/
    public static list<string> getLibraryCopyFieldset()
    {
        // get placement content fieldset list
        List<Schema.FieldSetMember> list_fldset = SObjectType.Placement_Library__c.FieldSets.Placement_Content_Fields.getFields();
        list<string> list_ApiFields = new list<string>();        
        for(Schema.FieldSetMember fld : list_fldset)
        {
            // adding field api name to list 
            list_ApiFields.add(fld.getFieldPath());
        }
        return list_ApiFields;
    }
    
    /*
 	* Name 	      : getAddLibraryFieldset
	* Description : This method is used to get fieldset(LayoutAddLibraryFields) from libarary object
 	* return      : returns list of fields api names
 	*/
    public static list<string> getAddLibraryFieldset()
    {
        // get placement content fieldset list
        List<Schema.FieldSetMember> list_fldset = SObjectType.Placement_Library__c.FieldSets.LayoutAddLibraryFields.getFields();
        list<string> list_ApiFields = new list<string>();        
        for(Schema.FieldSetMember fld : list_fldset)
        {
            // adding field api name to list 
            list_ApiFields.add(fld.getFieldPath());
        }
        return list_ApiFields;
    }
    
    /*
 	* Name 	      : generateRandomString
	* Description : This method is used to generate random string 
 	* return      : returns string
 	*/
    public static String generateRandomString(Integer len) 
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    /*
 	* Name 	      : getSobjectSoql
	* Description : This method is used to get soql string of sobject with all fields
	* Param		  : objVariable - sobject(ex Account acct,objVariable = acct)
 	* return      : returns string
 	*/
    public static string getSobjectSoql(SObject objVariable)
    {   
        String detailSoql = '';
        if(string.valueOf(objVariable.getSObjectType()) == 'Placement_Content__c' || string.valueOf(objVariable.getSObjectType()) == 'Placement_Library__c'){
            Placement_Content_Detail__c obj_ContDetail = new Placement_Content_Detail__c();
            detailSoql += ' ( ' +DGTL_DataAccessor.getSobjectSoql(obj_ContDetail) + 'ORDER BY S_No__c ';
            detailSoql += +') ';
            detailSoql = detailSoql.replace('Placement_Content_Detail__c', 'Placement_Content_Details__r');
        }
        
        string strsoql = 'SELECT LastModifiedBy.Name,';
        List<Schema.SObjectType> objects = new List<Schema.SObjectType>{ objVariable.getSObjectType()};
            for(Schema.SObjectType objType: objects){
                for(Schema.SObjectField fld: objType.getDescribe().fields.getMap().values()){
                    strsoql +=  fld.getDescribe().getName()+',';
                }
            }
        strsoql = strsoql.removeEnd(',');
        if(String.isNotBlank(detailSoql)){
            strsoql += ', '+ detailSoql + ' ';
        }
        strsoql += ' FROM '+ string.valueOf(objVariable.getSObjectType() +' WHERE Name !=null ');
        system.debug('--strsoql-'+strsoql);
        return strsoql;
    }
    
    /*
 	* Name 	      : getFieldLabels
	* Description : This method is used to labels of fields from object
	* Param		  : objApiName - object api name,list_Fields - list of api fields 
 	* return      : returns Map(KEY-Api Name,VALUE-Field Label)
 	*/
    public static Map<String,String> getFieldLabels(string objApiName,list<string> list_Fields)
    {
       Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
       Schema.SObjectType contentSchema = schemaMap.get(objApiName);
       Map<String, Schema.SObjectField> fieldMap = contentSchema.getDescribe().fields.getMap();
       Map<String,String> map_FieldApiLabel = New Map<String,String>();
       for(string s : list_Fields){
            map_FieldApiLabel.put(s,fieldMap.get(s).getDescribe().getLabel());
       }
       
        return map_FieldApiLabel;
    }
    
    /*
 	* Name 	      : getFloorsetPlan
	* Description : This method is used to get list of floorset plans
	* param       : floorsetPlanId - floorset plan record id,brand - selected brand(VS/PINK/SWIM/Beauty etc)
    * param       : dateVal - selected date to search,   timeval - selected time 
 	* return      : returns list of floorset plans
 	*/
  /*  public static list<DGTL_Floorset_Plan__c> getFloorsetList(string strSoql,string floorsetPlanId,string brand,string type,date dateVal,decimal timeint,string timestr)
    {        
        list<DGTL_Floorset_Plan__c> list_Floorset = new list<DGTL_Floorset_Plan__c>();
        if(String.isNotEmpty(floorsetPlanId)){
            strSoql += ' AND Id=:floorsetPlanId';
        }
        if(String.isNotEmpty(brand)){
            strSoql += ' AND Brands__c=:brand';
        }
        if(String.isNotEmpty(type)){
            strSoql += ' AND Type__c=:type';
        }
        if(String.isNotEmpty(timestr)){
            strSoql += ' AND Time__c=:timestr';
        }
        if(dateVal != null){
            strSoql += ' AND Date__c=:dateVal';
        }
        if(timeint != null){
            strSoql += ' AND Time_No__c=:timeint';
        }
        list_Floorset = Database.query(strSoql);
        return list_Floorset;
        
    } */
    
    /*
 	* Name 	      : getAllFieldApi
	* Description : This method is used to get list of field Api 
	* param       : objectApiName - name of the object for which we need the field API's
 	* return      : returns list of field API's for the given sObject
 	*/
    public static list<String> getAllFieldApi(String objectApiName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        list<String> list_Fields = new list<String>();
        for(String fieldApi : fieldMap.keyset()){
            list_Fields.add(fieldApi);
        }
        return list_Fields;
    } 
    
    /*
 	* Name 	      : getAllFieldApi
	* Description : This method is used to get list of field Api 
	* param       : objectApiName - name of the object for which we need the field API's
 	* return      : returns list of field API's for the given sObject
 	*/
    public static list<String> getHistoryTrackingFields(String objectApiName){
        
        list<String> writefieldsList = new list<String>();
        Id recordTypeId = Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Field Access').getRecordTypeId();
        
        for(DGTL_Access_Management__c AM : [select id,Object_Name__c, Writable_Fields__c,Tab_Name__c 
                                            from DGTL_Access_Management__c 
                                            where  Object_Name__c = :objectApiName  
                                            and Tab_Name__c = 'History Tracking'
                                            and recordTypeId =:recordTypeId ])
        {
            if(string.IsNotBlank(AM.Writable_Fields__c)){
                writefieldsList = AM.Writable_Fields__c.split(';');
                
            }
        }
        return writefieldsList;
    } 
    
    
     /*
 	* Name 	      : getPicklistValues
	* Description : This method is used to get picklist values for any picklist field from its object 
	* param       : ObjectApi_name - name of the object of which we need the picklist values
	* param		  : Field_name - name of Picklist field
 	* returns     : returns list of Picklist values for given field
 	*/
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        
        return lstPickvals;
    }    
   
   /*
 	* Name 	      : getPublicGroupMembers
	* Description : This method is used to get group name and group Members 
	* param       : publicGroupName - set of group names
 	* returns     : returns Map 
 	*/
    Public static map<string, list<id>>  getPublicGroupMembers(set<string> publicGroupName){ // getting - Members of the Public Group
        map<string, list<id>> map_GroupMem = new map<string, list<id>>();
         for(GroupMember gm : [SELECT Group.Name, UserOrGroupId, Group.Developername
                              FROM GroupMember WHERE Group.Name IN :publicGroupName])
        { 
            system.debug('----Group.Name' + gm.Group.Name);
            if(map_GroupMem.get(gm.Group.Name) == null)   map_GroupMem.put(gm.Group.Name, new list<id>{gm.UserOrGroupId});
            else map_GroupMem.get(gm.Group.Name).add(gm.UserOrGroupId);
        }
        system.debug('--map_GroupMem--'+map_GroupMem);
        return map_GroupMem;
    }
    
    /*
 	* Name 	      : getObjectFieldLabelAndApi
	* Description : This method is used to get group name and group Members 
	* param       : publicGroupName - set of group names
 	* returns     : returns Map 
 	*/
    Public static  Map<String,String>  getObjectFieldLabelAndApi(string objectName){ 
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        Map<String,String> objectFieldMap = new Map<String,String>();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            if(sfield.getDescribe().isUpdateable()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                objectFieldMap.put(dfield.getname(),dfield.getLabel());
                //system.debug('@@@API Name :' + dfield.getname()); system.debug('####Label Name : ' + dfield.getLabel ());
            }
        }
        return objectFieldMap;
    }
    
     /*
      *   Description   : This Method is used to get logged in user brand 
      *   Return        : String - logged user brand
      */
    public static string getUserBrand()
    {
        return [select Id,DGTL_Brands__c from User where id=:UserInfo.getUserId()].DGTL_Brands__c;
        
    }
    
    /*
      *   Description   : This Method is used to get logged in user details
      *   Return        : User - logged user 
      */
    public static User getUserDetails()
    {
        return [select Id,DGTL_Brands__c,DGTL_Profile__c from User where id=:UserInfo.getUserId()];
        
    }
    
    
    /*
 	* Name 	      : getPreviousLayoutContents
	* Description : This method is used to clone contents and contents details 
	* param       : layId - Placement_Layout__c id
 	* returns     : returns Map 
 	*/
    public static Map<Placement_Content__c,List<Placement_Content_Detail__c>> getPreviousLayoutContents(Id layId){
        Map<Placement_Content__c,List<Placement_Content_Detail__c>> map_ContAndDetail = new Map<Placement_Content__c,List<Placement_Content_Detail__c>>();
        string contSoql = getSobjectSoql(new Placement_Content__c()) + ' AND Placement_Layout__c=:layId AND Type__c !=\'Escalation\' order by Type__c ,S_No__c';
        for(Placement_Content__c cont : Database.query(contSoql)){
            // clone content
            Placement_Content__c cloneCont = cont.clone();
            cloneCont.Placement_Layout__c = null;
            cloneCont.Compare_Type__c = '';
            list<Placement_Content_Detail__c> list_Detail = new list<Placement_Content_Detail__c>();
            if(cont.Placement_Content_Details__r != null && !cont.Placement_Content_Details__r.isEmpty()){
                for(Placement_Content_Detail__c det : cont.Placement_Content_Details__r){
                    det.Placement_Content_Detail_Self__c = null;
                    det.Id = null;
                }
            }
            // clone content details
            list_Detail.addAll(cont.Placement_Content_Details__r.clone());
            map_ContAndDetail.put(cloneCont,list_Detail);
        }
        return map_ContAndDetail;
    }
    
}