/*****
 * Name         : DGTL_LayoutisEditorials
 * Description  : This Class is used to get editorials layouts
 * Author       : Vidya Sagar 
 * Component    : This class is controller for lightning compoenent DGTL_LayoutisEditorials.cmp
****/
public class DGTL_LayoutisEditorials {
    /**
    * @description	This Method is used to get editorials layouts
    * @param		selectedBrand - selected brand,pageType - selected page type,floorsetId - selected floorset,deviceType - selected device type
    * @return       Map - key- layout id, value - collection page name
    */
    @AuraEnabled
    public static Map<String, String> fetchEditorialLayouts(String selectedBrand,String pageType,string floorsetId,string deviceType)
    {
       // system.debug('--'+selectedBrand+'--'+pageType+'--'+floorsetId+'--'+deviceType);
        Map<String, String> options = new Map<String, String>();
        Id floorId = Id.valueof(floorsetId);
        list<Placement_Layout__c> list_Editorials = new list<Placement_Layout__c>();
        Placement_Layout__c obj_Layout = new Placement_Layout__c();
        // get editorial  layouts
        list_Editorials = DGTL_DataAccessor.getLayoutList(DGTL_DataAccessor.getSobjectSoql(new Placement_Layout__c()),selectedBrand,pageType,null,null,'Layout','',deviceType,floorId);
        for(Placement_Layout__c lay :list_Editorials){
            if(string.isNotBlank(lay.Collection_Page_Name__c))
            options.put( string.valueOf(lay.Id), lay.Collection_Page_Name__c);
        }
        return options;
    }
    
    /**
    * @description	This Method is used to get selected editorials layout details
    * @param		selectedEditorial - selected editorial layout id
    * @return       object - Placement_Layout__c object with details
    */
    @AuraEnabled
    public static Placement_Layout__c fetchEditorial(String selectedEditorial)
    {        
        return [select id,Collection_Page_Name__c,Collection_Page_Url__c from Placement_Layout__c where id=:selectedEditorial]; 
    }
    
   
}