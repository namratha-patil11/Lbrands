/* Name        : DGTL_PlacementLibraryTriggerHandler
 * Description : This class is used in DGTL_PlacementLibraryTrigger.trigger
 * Author      : Vidya Sagar
 * 
 */
public class DGTL_PlacementLibraryTriggerHandler 
{
    
     /*    Description : This method is called in DGTL_PlacementLibraryTrigger, beforeinsert and before update
      *                  This method is used to update name with concatenation 
      *    Param       : list_PlcLibraryNew - list trigger.new values,  map_PlcLibraryOld - map of old values
      */
    public static void updateDefaults(List<Placement_Library__c> list_PlcLibraryNew,Map<Id,Placement_Library__c> map_PlcLibraryOld)
    {
        for(Placement_Library__c pll : list_PlcLibraryNew)
        {
            if(pll.Start_Minute__c == null)
              pll.Start_Minute__c = '00';
            if(pll.End_Minute__c == null)
              pll.End_Minute__c = '00';
            if(pll.Offer_Type__c == 'Non Offer')
            {
                pll.Status__c = 'Approved';
            }
            else if(pll.Offer_Type__c == 'Offer' && ((map_PlcLibraryOld == Null) || (map_PlcLibraryOld != Null && map_PlcLibraryOld.get(pll.Id).Offer_Type__c != 'Offer')))
            {
                pll.Status__c = 'Submitted';
            }           
            // updating Name with Brand-PageType-placement type
            if(map_PlcLibraryOld == Null || (pll.Brands__c != map_PlcLibraryOld.get(pll.Id).Brands__c || pll.Page_Types__c != map_PlcLibraryOld.get(pll.Id).Page_Types__c || pll.Placement_type__c != map_PlcLibraryOld.get(pll.Id).Placement_type__c || pll.Main_Message__c != map_PlcLibraryOld.get(pll.Id).Main_Message__c))
            {
                pll.Name = '';
                if(pll.Brands__c != null )
                {
                    pll.Name = pll.Brands__c;
                }
                if(pll.Page_Types__c != null )
                {
                    pll.Name += ' - '+ pll.Page_Types__c;
                }
                if(pll.Placement_type__c != null )
                {
                    pll.Name += ' - '+ pll.Placement_type__c;
                }
                if(pll.Main_Message__c !=null)
                {
                    Integer len = 0;
                    if(pll.Name !=null){
                        len = 75 - pll.Name.length();
                    }                        
                    if(pll.Main_Message__c.length() <= len)
                    {
                        pll.Name += ' - '+pll.Main_Message__c;
                    }else{
                        pll.Name +=  ' - '+pll.Main_Message__c.substring(0,len);
                    } 
                }
            }
            
            // checks for LTO's page types and collection page url
            if(pll.Page_Types__c != 'LTO' && pll.Collection_Page_Url__c != null && pll.Page_Types__c != 'Editorials')
               {
                   pll.Collection_Page_Url__c = null;
               }
        }
    }
    
     /*    Description : This method is called in DGTL_PlacementLibraryTrigger after insert 
      *                  cloning content details when library is cloned 
      *    Param       : list_PlcLibraryNew - list trigger.new values
      */
     
    public static void cloneContentDetails(List<Placement_Library__c> list_PlcLibraryNew){
        list<Id> list_ClonedIds = new list<Id>();
        map<Id,Id> map_CloneIdNewId = new map<Id,Id>();
        // trigger.new for loop
        for(Placement_Library__c pll : list_PlcLibraryNew)
        {
            // check for if library is cloned
            if(pll.isClone()){                
                list_ClonedIds.add(pll.getCloneSourceId());
                map_CloneIdNewId.put(pll.getCloneSourceId(),pll.Id);
            }
        }
        if(!list_ClonedIds.isEmpty()){
            Placement_Content_Detail__c obj_ContDetail = new Placement_Content_Detail__c();
            list<Placement_Content_Detail__c> list_ContDetails = new list<Placement_Content_Detail__c>();
            list<Placement_Content_Detail__c> list_OldContDetails = new list<Placement_Content_Detail__c>(); 
            // get content details related to library
            string soql_ContDetail =  DGTL_DataAccessor.getSobjectSoql(obj_ContDetail)+' AND Placement_Library__c IN :list_ClonedIds';
            soql_ContDetail = soql_ContDetail.remove('CloneSourceId,');
            // get content details of old library
            list_OldContDetails = Database.query(soql_ContDetail);
            for(Placement_Content_Detail__c contDet : list_OldContDetails){ 
                // clone content detail
                Placement_Content_Detail__c contDetail = contDet.clone();
                contDetail.Placement_Library__c = map_CloneIdNewId.get(contDet.Placement_Library__c);
                contDetail.Placement_Content__c = null;
                contDetail.OwnerId = UserInfo.getUserId();
                list_ContDetails.add(contDetail);
            }
            // insert cloned content details
            if(!list_ContDetails.isEmpty()){
                insert list_ContDetails;
            }
            
        }
    }
    
}