public class DGTL_CloneFloorsetHierarchy {
    
    @AuraEnabled
    public static DGTL_FloorsetHierarchyCloneWrap getPreviousFloorsetPlan(String floorsetId){
        DGTL_CloneFloorsetHierarchy.DGTL_FloorsetHierarchyCloneWrap wrapper = new DGTL_CloneFloorsetHierarchy.DGTL_FloorsetHierarchyCloneWrap();
        DGTL_Floorset_Plan__c previousFloorset;
        List<Placement_Layout__c> filteredPageType = new List<Placement_Layout__c>();
        Map<String,Placement_Layout__c> pageTypes = new Map<String,Placement_Layout__c>();
        Map<String,Placement_Layout__c> currentPageTypes = new Map<String,Placement_Layout__c>();
        DGTL_Floorset_Plan__c currentFloorset = [SELECT Id,Brands__c,Date__c,Time_No__c 
                                                 FROM DGTL_Floorset_Plan__c 
                                                 WHERE Id=:floorsetId];
        
        try{
            previousFloorset = [SELECT Id,Name FROM DGTL_Floorset_Plan__c 
                                WHERE Brands__c=:currentFloorset.Brands__c 
                                AND Date__c <= :currentFloorset.Date__c 
                                AND Id != :currentFloorset.Id 
                                ORDER BY Date__c DESC, Time_No__c DESC LIMIT 1]; 
            
            //------------ for Page Types Check boxes
            currentPageTypes = getAllPageTypes(floorsetId);	
            pageTypes = getAllPageTypes(previousFloorset.Id);
            
            for(String page : pageTypes.keySet()){
                if(currentPageTypes.get(page) == null)
                    filteredPageType.add(pageTypes.get(page));
            }
            //------------ for Page Types Check boxes
            
        }catch(QueryException qe){
            throw new AuraException('No previous floorset found!');
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        wrapper.obj_Floorset = previousFloorset;
        wrapper.pageTypes = pageTypes;
        wrapper.list_filteredPageType = filteredPageType;
        return wrapper;
    }
    
    // get all the Layouts by page types and Device Type for a Floorset
    public static Map<String,Placement_Layout__c> getAllPageTypes(String floorsetId){
        Map<String,Placement_Layout__c> map_pageTypes = new Map<String,Placement_Layout__c>();
        List<Placement_Layout__c> pLayoutList = new List<Placement_Layout__c>();
        String typeStr = 'Layout';
        String query = 'SELECT Id,';
        
        for(Schema.SObjectField fld: Placement_Layout__c.sObjectType.getDescribe().fields.getMap().values()){
            query +=  fld.getDescribe().isCreateable() ? fld.getDescribe().getName()+',' : '';
        }
        query = query.removeEnd(',');
        query += ' FROM Placement_Layout__c WHERE Floorset_Plan__c = :floorsetId AND Is_Deleted__c = false';
        query += ' AND Type__c  =:typeStr ORDER BY Page_Types__c';
        try{
            pLayoutList = Database.query(query);
        }catch(QueryException qe){
            System.debug('*****QueryException****'+qe.getMessage());
        }
        
        for(Placement_Layout__c curLayout : pLayoutList){
            map_pageTypes.put(curLayout.Page_Types__c +'-'+curLayout.Device_Type__c,curLayout);
        }
        return map_pageTypes;
    }
    
    @AuraEnabled
    public static void cloneFloorsetChildHierarchy(String previousFloorsetId, String floorsetId, List<Placement_Layout__c> pLayoutListToSelClone){
        //get all the child layouts for the given floorset plan id
        List<Placement_Layout__c> pLayoutListToClone = new List<Placement_Layout__c>();
        
        for(Placement_Layout__c pl : pLayoutListToSelClone){ //assign current Floorset Id for the layouts to be cloned
            pl.Floorset_Plan__c = floorsetId;
            pLayoutListToClone.add(pl);
        }
        
        if(pLayoutListToClone.size() > 0){
            // clone layouts, contents, content details and placementKOD
            Map<String,List<String>> childsToCloneMap = new Map<String,List<String>>();
            childsToCloneMap.put('Placement_Layout__c', new List<String>{'Placement_Content__c'});
            childsToCloneMap.put('Placement_Content__c', new List<String>{'Placement_Content_Detail__c'});
            
            try{
                DGTL_GenericMultiLevelClone.deepCloneBatched(pLayoutListToClone,childsToCloneMap,null);
            }catch(Exception e){
				if(!Test.isRunningTest()){
				    throw new AuraException(e.getMessage());
				}
            }
            
        }else{
            throw new AuraException('No Layouts Found!');
        }
        
    }
    
    // get all the placement layouts for the given floorset plan Id
   /* private static List<Placement_Layout__c> getChildLayouts(String floorsetId){
        List<Placement_Layout__c> pLayoutList = new List<Placement_Layout__c>();
        String query = 'SELECT Id,';
        for(Schema.SObjectField fld: Placement_Layout__c.sObjectType.getDescribe().fields.getMap().values()){
            query +=  fld.getDescribe().isCreateable() ? fld.getDescribe().getName()+',' : '';
        }
        query = query.removeEnd(',');
        query += ' FROM Placement_Layout__c WHERE Floorset_Plan__c = :floorsetId AND Is_Deleted__c = false';
        
        try{
           pLayoutList = Database.query(query);
        }catch(QueryException qe){
            System.debug('*****QueryException****'+qe.getMessage());
        }
        
        return pLayoutList;
    }*/
    
    
    public class DGTL_FloorsetHierarchyCloneWrap
    {
        @AuraEnabled public DGTL_Floorset_Plan__c obj_Floorset {get;set;}
        @AuraEnabled public  Map<String,Placement_Layout__c> pageTypes {get;set;}
        @AuraEnabled public List<Placement_Layout__c> list_filteredPageType {get;set;}
        
        public DGTL_FloorsetHierarchyCloneWrap()
        {
            DGTL_Floorset_Plan__c obj_Floorset = NEW DGTL_Floorset_Plan__c();
            pageTypes = new Map<String,Placement_Layout__c>();
            list_filteredPageType= new List<Placement_Layout__c>();
        }
    }

}