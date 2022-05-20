public class DGTL_LayoutABTesting {

    /*
    *   This Method is used to get AB Testing layouts
    *   Component helper method : fetchContentJsHpr
    */
    @AuraEnabled
    public static Map<String, String> fetchABTestLayouts(String selectedBrand,String pageType,string floorsetId,string deviceType)
    {
        Map<String, String> options = new Map<String, String>();
        Placement_Layout__c obj_Lay = new Placement_Layout__c();
        Id floorId = Id.valueof(floorsetId);
        list<Placement_Layout__c> list_ABTesting = new list<Placement_Layout__c>();
        Placement_Layout__c obj_Layout = new Placement_Layout__c();
        list_ABTesting = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(obj_Layout),selectedBrand,pageType,null,null,'Testing','',deviceType,floorId);
        for(Placement_Layout__c lay :list_ABTesting){
            options.put( string.valueOf(lay.Id), lay.Test_Name__c);
        }
        return options;
    }
    
   /*
    *   This Method is used to create new editorial layout
    *   Component helper method : addEditorialHpr
    */
    @AuraEnabled
    public static string createTestLayout(String selectedBrand,String pageType,string floorsetId,string deviceType,string pageName,string selectedTest,list<Placement_Content__c> list_Content)
    {
        try{
            Placement_Layout__c obj_Lay = new Placement_Layout__c();
            DGTL_Floorset_Plan__c obj_Floorset = new DGTL_Floorset_Plan__c();
            obj_Floorset = DGTL_DataAccessor.getFloorsetPlanList(DGTL_DataAccessor.getSobjectSoql(obj_Floorset),floorsetId,'Search',null)[0];            
            obj_Lay.Floorset_Plan__c = Id.valueof(floorsetId);
            obj_Lay.Brands__c = selectedBrand;
            obj_Lay.Page_Types__c = pageType;
            obj_Lay.Device_Type__c = deviceType;
            if(String.isNotEmpty(pageName)){
                obj_Lay.Test_Name__c = pageName;
            }
            obj_Lay.Type__c = 'Testing';
            if(String.isNotEmpty(selectedTest) && selectedTest !='None'){
                obj_Lay.Id = selectedTest;
            }
            upsert obj_Lay;
            if(!list_Content.isEmpty()){
                list<Id> list_ContId = new list<Id>();
                Placement_Content__c obj_cont = new Placement_Content__c();
                list<Placement_Content__c> list_ContInsert = new list<Placement_Content__c>();
                for(Placement_Content__c cont :list_Content){
                    list_ContId.add(cont.Id);
                }
                string soql_cont = DGTL_DataAccessor.getSobjectSoql(obj_cont);
                soql_cont += ' AND Id In : list_ContId';
                list_ContInsert = Database.query(soql_cont);
                     system.debug('--list_Content--'+list_Content[0].Id);
                    // cloning selected contents and adding into new content list 
                    map<string, list<string>> map_ChildsToClone = new map<string, list<string>>();
                    map_ChildsToClone.put('Placement_Content__c', new list<string>{'Placement_Content_Detail__c'});
                    map<string, map<string, string>> map_StaticValues = new map<string, map<string, string>>();
                    map_StaticValues.put('Placement_Content__c', new map<string, string>{'Placement_Layout__c' => obj_Lay.Id, 'Placement_Library__c' => null});
                    DGTL_GenericMultiLevelClone.deepCloneBatched(list_ContInsert, 
                                                                map_ChildsToClone, 
                                                                map_StaticValues );
                }
            return string.valueOf(obj_Lay.Id);
        }catch(exception ex){            
                return 'Error: '+string.valueof(ex);
            
        }
        
    }
}