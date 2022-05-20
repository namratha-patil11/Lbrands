/* Name        : DGTLFloorsetPlanServices
 * Description : This class is used in DGTLFloorsetPlanTriggerHandler.cls
 * Author      : Vidya Sagar
 * 
 */
public without sharing class DGTLFloorsetPlanServices {

     
     /*   Description : This method is called in DGTLFloorsetPlanTriggerHandler, beforeinsert method
      *                 This method is used to update name with and unique name field with concatenation of brand, date,time and type 
      *   Param       : floorsetPlanList - trigger.new values before insert 
      */
     public static void defaultFieldValues(List<DGTL_Floorset_Plan__c > floorsetPlanList){
           
         Map<Id,DGTL_Floorset_Plan__c> oldMap_Floorset = trigger.isUpdate ? (Map<Id,DGTL_Floorset_Plan__c>)trigger.oldMap : null ; 
         for(DGTL_Floorset_Plan__c flr : floorsetPlanList){
             if(oldMap_Floorset != null && !oldMap_Floorset.isEmpty()){
                 // error message to restrict brand change 
                 if(flr.Brands__c != oldMap_Floorset.get(flr.Id).Brands__c)
                    flr.Brands__c.addError('Brand cannot be changed');
             }
             string strTime ;
             if(flr.Minute__c != null){
                 strTime = flr.Time__c.substringBefore(' ')+':'+ flr.Minute__c+' '+flr.Time__c.substringAfter(' ');             
             }else{
                 flr.Minute__c = '00';
                 strTime = flr.Time__c.substringBefore(' ')+':00 '+flr.Time__c.substringAfter(' ');             
             }
            flr.Name = flr.Brands__c+' - '+flr.Date__c.Month()+'/'+flr.Date__c.Day()+'/'+flr.Date__c.Year()+' - '+strTime+' - '+flr.Type__c; 
            //flr.Unique_Name__c = flr.Brands__c+' - '+flr.Date__c.Month()+'/'+flr.Date__c.Day()+'/'+flr.Date__c.Year()+' - '+strTime+' - '+flr.Type__c; 
            flr.Unique_Name__c = flr.Brands__c+' - '+flr.Date__c.Month()+'/'+flr.Date__c.Day()+'/'+flr.Date__c.Year()+' - '+strTime; // request change for remove type in unique field
        }
        
     }
     
     /*   This method is called in DGTLFloorsetPlanTriggerHandler, afterUpdate method
      *   This method is used to update Layout name when floorset date/type/time changed
      *   @ Param floorsetIds : Floorset Ids 
      */
    /* public static void updateLayoutNames(List<DGTL_Floorset_Plan__c > floorsetPlanList){
         system.debug('----floorsetPlanList--updateLayoutNames---'+floorsetPlanList);
         List<Id> list_UpdatedFloorsetIds = new List<Id>();
         Map<Id,DGTL_Floorset_Plan__c> oldMap_Floorset = trigger.isUpdate ? (Map<Id,DGTL_Floorset_Plan__c>)trigger.oldMap : null ; 
         system.debug('----oldMap_Floorset--'+oldMap_Floorset);
         for(DGTL_Floorset_Plan__c flr : floorsetPlanList){
              system.debug('----check name--'+flr.Name+'---'+oldMap_Floorset.get(flr.Id).Name);
                 if(flr.Name != oldMap_Floorset.get(flr.Id).Name)
                    list_UpdatedFloorsetIds.add(flr.Id);
          }
          system.debug('----list_UpdatedFloorsetIds--'+list_UpdatedFloorsetIds);
          if(!list_UpdatedFloorsetIds.isEmpty()){
             List<Placement_Layout__c> list_UpdateLayouts = new List<Placement_Layout__c>();
             for(Placement_Layout__c lay : [select id,Name,Page_Types__c,Device_Type__c,Test_Name__c,Unique_Id__c from Placement_Layout__c where Floorset_Plan__c IN :list_UpdatedFloorsetIds]){
                    list_UpdateLayouts.add(lay);
                    system.debug('----lay--'+lay);
                }
              if(!list_UpdateLayouts.isEmpty())
                 Update list_UpdateLayouts;
          } 
         
        
     } */
}