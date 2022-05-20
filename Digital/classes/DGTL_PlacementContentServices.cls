public class DGTL_PlacementContentServices {
    
    public static list<DGTL_Access_Management__c> getAccessManagement(list<string> str_Brand , String str_objectName) {
        id taskRecId =  Schema.SObjectType.DGTL_Access_Management__c.getRecordTypeInfosByName().get('Task Creation').getRecordTypeId();
        map<String,list<DGTL_Access_Management__c>> map_BrandAccessMgmt = New map<String,list<DGTL_Access_Management__c>>();
        
        list<DGTL_Access_Management__c> list_AccessMgmt = [select name, Team__c,Read_Only_Fields__c,Brands__c 
                                                           from DGTL_Access_Management__c where 
                                                           Brands__c IN : str_Brand  and Read_Only_Fields__c != null 
                                                           AND Object_Name__c =: str_objectName
                                                           AND RecordTypeId =: taskRecId AND Team__c != null];
        
        for(String brand : str_Brand){
            list<DGTL_Access_Management__c> list_BrandAccessMgmt = New list<DGTL_Access_Management__c>();
            for(DGTL_Access_Management__c accessMgmt : list_AccessMgmt){
                if(accessMgmt.Brands__c == brand) list_BrandAccessMgmt.add(accessMgmt);
            }
            map_BrandAccessMgmt.put(brand,list_BrandAccessMgmt);
        }
        
        return list_AccessMgmt;
        
    }
    
    public static map<String,list<DGTL_Access_Management__c>> getAccessManagementMap(list<string> str_Brand,String str_objectName) {
        map<String,list<DGTL_Access_Management__c>> map_BrandAccessMgmt = New map<String,list<DGTL_Access_Management__c>>();
        list<DGTL_Access_Management__c> list_AccessMgmt = getAccessManagement(str_Brand,str_objectName);
        for(String brand : str_Brand){
            list<DGTL_Access_Management__c> list_BrandAccessMgmt = New list<DGTL_Access_Management__c>();
            for(DGTL_Access_Management__c accessMgmt : list_AccessMgmt){
                if(accessMgmt.Brands__c == brand) list_BrandAccessMgmt.add(accessMgmt);
            }
            map_BrandAccessMgmt.put(brand,list_BrandAccessMgmt);
        }
        
        return map_BrandAccessMgmt;
    }
    
    public static void defaultValuesOnBefore(List<Placement_Content__c> list_PayConts,Map<Id,Placement_Content__c> map_PlContOld)
    {
        Set<Id> set_PlacLayIds = New Set<Id>();
        Map<Id,Placement_Layout__c> map_PlacLayout = New Map<Id,Placement_Layout__c>();
        
        //Get all the layout ids
         for(Placement_Content__c pCon : list_PayConts)
        {  
            if(Trigger.isBefore && Trigger.isInsert){
                pCon.Row_Start__c = True;
                pCon.Compare_Type__c = '';
            }
           if(pCon.Id == null || (pCon.Id != null && pCon.Type__c != 'Escalation')){
               system.debug('pCon.Placement_Layout__c--'+pCon.Placement_Layout__c);   system.debug('pCon.Placement_Library__c--'+pCon.Placement_Library__c);
               system.debug('pCon.Type__c--'+pCon.Type__c);   system.debug('pCon.AB_Test_Name__c--'+pCon.AB_Test_Name__c);
                pCon.Unique_Field__c = pCon.Placement_Layout__c + '-'+ pCon.Placement_Library__c +  '-' + pCon.Type__c  + '-' + pCon.AB_Test_Name__c;
            }           
            //Populate Name Field
           // if(map_PlContOld == null || 
             //  (pCon.Placement_Layout__c != map_PlContOld.get(pCon.Id).Placement_Layout__c || 
               // pCon.Placement_type__c != map_PlContOld.get(pCon.Id).Placement_type__c || 
                //pCon.Main_Message__c != map_PlContOld.get(pCon.Id).Main_Message__c)) {
                    set_PlacLayIds.add(pCon.Placement_Layout__c);
                //}
        }
                
        if(set_PlacLayIds.isEmpty()) return;
        for(Placement_Layout__c ply : [SELECT Id,Name,Type__c,Compared_Placement_Layout__c,Page_Types__c FROM Placement_Layout__c WHERE Id IN :set_PlacLayIds]) {            
            map_PlacLayout.put(ply.Id,ply);
        }
        
        for(Placement_Content__c pCon : list_PayConts)
        {
            if(map_PlacLayout.containskey(pCon.Placement_Layout__c))
            {
                //String pCOnName = map_PlacLayIdsNames.get(pCon.Placement_Layout__c);
                String pCOnName = map_PlacLayout.get(pCon.Placement_Layout__c).Name;
                Integer len = pCOnName !=null ? 75 - pCOnName.length() : 0;
                if(pCon.Placement_type__c !=null && len > 0){
                    pCOnName += pCon.Placement_type__c.length() <= len ? ' - '+pCon.Placement_type__c : ' - '+pCon.Placement_type__c.substring(0,len);
                }
                len = pCOnName !=null ? 75 - pCOnName.length() : 0;
                if(pCon.Main_Message__c !=null && len > 0) {  
                    pCOnName += pCon.Main_Message__c.length() <= len ? ' - '+pCon.Main_Message__c : ' - '+pCon.Main_Message__c.substring(0,len);
                }  
                pCon.Name = pCOnName;
                
                // After Tasks are created for ComServ Team -- All the Placements Created except Escallation Content will be defaulted as InActive
                if(pCon.Id == null && pCon.Type__c != 'Escalation' && map_PlacLayout.get(pCon.Placement_Layout__c).Compared_Placement_Layout__c != null){
                    pCon.Active__c = false;
                }
                // checks for LTO'S page type and collection page url
                if(map_PlacLayout.get(pCon.Placement_Layout__c).Page_Types__c != 'LTO' && pCon.Collection_Page_Url__c != null){
                    pCon.Collection_Page_Url__c = null;
                }
            }            
            
        } 
        
    }
    
}
