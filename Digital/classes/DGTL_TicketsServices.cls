/* Name : DGTL_TicketsServices
 * Description : This class is used in DGTL_TicketsTriggerHandler.cls
 * Author : Vidya Sagar
 * Date     : 23 March 2020 
 */
public without sharing class DGTL_TicketsServices {

     
     /*   This method is called in DGTL_TicketsTriggerHandler, beforeinsert/beforeupdate method
      *   This method is used to update name with concatenation of reason - content name/layout name
      *   @ Param ticketsList : trigger.new values before insert 
      */
     public static void defaultFieldValues(List<DGTL_Tickets__c> ticketsList){
         
         Set<Id> set_layoutIds = new Set<Id>(); // used for layout ids
         Set<Id> set_ContIds = new Set<Id>(); // used for content ids
         Map<Id,String> map_IdName = new  Map<Id,String>(); // used for content/layout  id and name
         Id dataIssueRecordTypeId =   Schema.SObjectType.DGTL_Tickets__c.getRecordTypeInfosByDeveloperName().get('Data_Issues').getRecordTypeId();
         for(DGTL_Tickets__c tkt : ticketsList){
             if(tkt.RecordTypeId == dataIssueRecordTypeId){
                if(tkt.Layout__c != null)
                set_layoutIds.add(tkt.Layout__c);
                if(tkt.Placement_Content__c != null)
                set_ContIds.add(tkt.Placement_Content__c); 
             }
             
         }
         // adding layout id and layout name to map
         if(!set_layoutIds.isEmpty()){
             for(Placement_Layout__c lay : [select id,Name from Placement_Layout__c where Id IN:set_layoutIds]){
                 map_IdName.put(lay.Id,lay.Name);
             }
         }
         // adding Content id and content name to map
         if(!set_ContIds.isEmpty()){
             for(Placement_Content__c cont : [select id,Name from Placement_Content__c where Id IN:set_ContIds]){
                 map_IdName.put(cont.Id,cont.Name);
             }
         }
         for(DGTL_Tickets__c tkt : ticketsList){
             // check for RecordTypeId for data issue record type 
             if(tkt.RecordTypeId == dataIssueRecordTypeId){
                 // updating name with reason
                 tkt.Name = tkt.Reason__c; 
                 Integer len = tkt.Name !=null ? 75 - tkt.Name.length() : 0;
                 Integer newlen ;
                 // updating name with content name/layout name
                 if(tkt.Placement_Content__c !=null && map_IdName.containsKey(tkt.Placement_Content__c)){
                     newlen = map_IdName.get(tkt.Placement_Content__c).length();
                         if(len > newlen )
                         tkt.Name += ' - '+map_IdName.get(tkt.Placement_Content__c).substring(0,newlen);
                         else
                         tkt.Name += ' - '+map_IdName.get(tkt.Placement_Content__c).substring(0,len);
                 }else if(tkt.Layout__c !=null && map_IdName.containsKey(tkt.Layout__c) ){
                     newlen = map_IdName.get(tkt.Layout__c).length();
                         if(len > newlen)
                         tkt.Name += ' - '+map_IdName.get(tkt.Layout__c).substring(0,newlen);
                         else
                         tkt.Name += ' - '+map_IdName.get(tkt.Layout__c).substring(0,len);
                 } 
                 
             }
         }
     }
     
}