public class DGTL_PlacementLayoutTriggerHandler 
{
    public static void updateplacementLayoutExtId(List<Placement_Layout__c> list_PayLayOuts,Map<Id,Placement_Layout__c> map_PlcLayOld)
    {
        List<String> list_FloorsetPlanIds = New List<String>();
        Map<String,String> map_FloorsetPlanIdsNames = New Map<String,String>();     
        for(Placement_Layout__c ply : list_PayLayOuts)
        {
            /*if(map_PlcLayOld == Null || (ply.Floorset_Plan__c != map_PlcLayOld.get(ply.Id).Floorset_Plan__c || 
                ply.Page_Types__c != map_PlcLayOld.get(ply.Id).Page_Types__c || ply.Device_Type__c != map_PlcLayOld.get(ply.Id).Device_Type__c || 
                ply.Collection_Page_Name__c != map_PlcLayOld.get(ply.Id).Collection_Page_Name__c || ply.Test_Name__c != map_PlcLayOld.get(ply.Id).Test_Name__c ))*/
                list_FloorsetPlanIds.add(ply.Floorset_Plan__c);
        }
        if(list_FloorsetPlanIds.isEmpty()) return;
        Integer randNum = 5;
        for(DGTL_Floorset_Plan__c flr : [SELECT Id,Name FROM DGTL_Floorset_Plan__c WHERE Id IN :list_FloorsetPlanIds])
        {
            map_FloorsetPlanIdsNames.put(flr.Id,flr.Name);
        }
        
        for(Placement_Layout__c ply : list_PayLayOuts)
        {                
            // updating Name with Floorset Plane Name - page type
            if(map_FloorsetPlanIdsNames.containsKey(ply.Floorset_Plan__c))
            {
                ply.Name = map_FloorsetPlanIdsNames.get(ply.Floorset_Plan__c);  
                ply.Name  += ply.Page_Types__c != null ? ' - '+ ply.Page_Types__c  : '';
                ply.Name += ply.Device_Type__c != null ? ' - '+ ply.Device_Type__c : '' ;
                ply.Name += ply.Test_Name__c != null ? ' - '+ ply.Test_Name__c : '';
            }
            ply.Unique_Id__c = ply.Name;
            
            if(ply.Type__c != null && (ply.Type__c == 'Layout' || ply.Type__c == 'Testing'))
            {
                ply.Unique_Id__c += ' - '+ply.Type__c;   
            }else{
                if(ply.Id != null){
                    ply.Unique_Id__c += ' - '+ply.Type__c + '-'+String.valueof(ply.Id);
                }                        
                else{
                    randNum++;
                    ply.Unique_Id__c += ' - '+ply.Type__c +'-'+ DGTL_DataAccessor.generateRandomString(randNum);
                }
                
            }    
            ply.Unique_Id__c += ply.Device_Type__c != null ? ' - '+ ply.Device_Type__c : '';
            ply.Unique_Id__c += ply.Collection_Page_Name__c != null ? ' - '+ ply.Collection_Page_Name__c : '';
            ply.Unique_Id__c += ply.Test_Name__c != null ? ' - '+ ply.Test_Name__c : '';            
        }
        
    }
    public static void updateFloorsetCalendar(List<Placement_Layout__c> list_PayLayOuts, Map<Id,Placement_Layout__c> map_PlcLayOld, Boolean context)
    {
        set<Id> list_FloorsetIds = new set<Id>();
        string baseurl = System.URL.getSalesforceBaseUrl().toExternalForm();
        map<Id,String> map_FloorsetLayouts = new map<Id,String>(); 
      
        if(context == true) {
            for(Placement_Layout__c lay : map_PlcLayOld.values())
            {
                list_FloorsetIds.add(lay.Floorset_Plan__c);  
            }
        }
        
        else{
            
            for(Placement_Layout__c lay:list_PayLayOuts)
            {
                list_FloorsetIds.add(lay.Floorset_Plan__c);
            } 
        }
        
     
        if(!list_FloorsetIds.isEmpty())
        {
            List<DGTL_Floorset_Plan__c> list_floorset = new List<DGTL_Floorset_Plan__c>();
            for(DGTL_Floorset_Plan__c flr : [select id,Layouts__c from DGTL_Floorset_Plan__c where id in :list_FloorsetIds]){
                map_FloorsetLayouts.put(flr.Id,'');
                list_floorset.add(flr);
           }
    
            for(Placement_Layout__c layout : [select Id,Name,Brands__c,Page_Types__c,Device_Type__c,Floorset_Plan__c from Placement_Layout__c where Floorset_Plan__c in :list_FloorsetIds and Type__c='Layout' and Is_Deleted__c=false])
            {
                string links = map_FloorsetLayouts.get(layout.Floorset_Plan__c);
                links += '<br/>';
                links += '<a href="'+baseurl+'/lightning/n/Layouts?c__brand='+layout.Brands__c+'&c__pagetype='+layout.Page_Types__c+'&c__device='+layout.Device_Type__c+'&c__floorset='+layout.Floorset_Plan__c+'">'+layout.Page_Types__c+' - '+layout.Device_Type__c+'</a>';
                links += '<br/>';
                map_FloorsetLayouts.put(layout.Floorset_Plan__c,links);
            }
            
            for(DGTL_Floorset_Plan__c flr : list_floorset)
            {
                flr.Layouts__c = map_FloorsetLayouts.get(flr.Id);    
            }
    
            update list_floorset;
        }
        
        
    }
    
       
}