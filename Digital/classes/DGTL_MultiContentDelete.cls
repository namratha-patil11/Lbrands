/**
* @description 			DGTL_MultiContentDelete - Used fot multi Content Delete - Component Name - DGTL_MultiContentDelete.
* @author       		Namratha P.
* @Created_date         Feb 2020.
* @Revised_date			March 11 2020 - Namratha P.
*/
public class DGTL_MultiContentDelete {
    
/**
* @description  getRelatedPlacements - this Initilizes the Component - DGTL_MultiContentDelete.
* @author       Namratha P , Revised - March 11 2020 - Namratha P.
* @param        content - recives a Content record which is selected for Delete.
* @return       DGTL_MultiContentDeleteWrapper - returns related contents associated with same Library as the selected Content.
*/
    @AuraEnabled
    public static DGTL_MultiContentDeleteWrapper getRelatedPlacements(Placement_Content__c content){
        List<Placement_Content__c> list_PlacementContents =  new list<Placement_Content__c>();
        DGTL_MultiContentDeleteWrapper wrapper = new DGTL_MultiContentDeleteWrapper();
        Date layoutDate;
        Decimal layoutTime;
        String type = content.Type__c;
        List<String> list_Type = new List<String>{'AB Test','Takedown','Contingency'};
            try{
                if(content != null && content.Placement_Library__c != null){
                    
                    for(Placement_Content__c typeContent : [SELECT 
                                                            Id,Name,Main_Message__c,Placement_type__c,Parent_Content__c,
                                                            Compared_Placement_Layout__c,Placement_Layout__c,
                                                            Placement_Layout__r.Date_Formula__c,Type__c,
                                                            Placement_Layout__r.Time_No__c 
                                                            FROM Placement_Content__c 
                                                            WHERE 
                                                            Id =:content.Id OR 
                                                            (
                                                                Parent_Content__c =: content.Id AND 
                                                                (
                                                                    Type__c IN:list_Type
                                                                )
                                                            )
                                                           ])
                    { // get associated AB Test,Takedown,Contingency records
                        if((typeContent.Parent_Content__c == content.Id) && list_Type.contains(typeContent.Type__c))
                            wrapper.list_nonControlled.add(typeContent);
                        
                        if(typeContent.Id == content.Id){ // get date and time of layout to get records from next layouts
                            layoutDate = typeContent.Placement_Layout__r.Date_Formula__c;
                            layoutTime = typeContent.Placement_Layout__r.Time_No__c;                             
                        }
                    }
                    // get Related contentes associated with the content with same Lib ID
                    for(Placement_Content__c contentInst : [SELECT 
                                                            Id,Name,Main_Message__c,Placement_Library__c,Compared_Placement_Layout__c,
                                                            Placement_Layout__r.Date_Formula__c,Placement_Layout__r.Time_No__c,
                                                            Placement_Layout__r.Type__c
                                                            FROM Placement_Content__c 
                                                            WHERE 
                                                            Type__c=:type AND 
                                                            Placement_Library__c=:content.Placement_Library__c AND 
                                                            Placement_Layout__r.Type__c ='Layout' AND 
                                                            (Placement_Layout__r.Date_Formula__c >=:layoutDate OR 
                                                             (
                                                                 Placement_Layout__r.Date_Formula__c =:layoutDate AND 
                                                                 Placement_Layout__r.Time_No__c >:layoutTime
                                                             )
                                                            )])
                    {
                        if(contentInst.Compared_Placement_Layout__c == null) wrapper.list_Contents.add(contentInst);
                        // add locked/ Processed Contents into list to display
                        else wrapper.list_LockedContents.add(contentInst);
                    }
                }
            }catch(exception e){
                system.debug('Error fetching related contents : '+e.getMessage());
            }      
        return wrapper;
    }
    
    
/**
* @description  deletePlacements - deletes contents with associated 'Takedown, AB Test and Contengency'- DGTL_MultiContentDelete.
* @author       Namratha P ,  Feb 2020.
* @param        list_Contents - recives a list of Content record which is selected for Delete.
* @return       String - returns Success if deletion was successfull.
*/
    @AuraEnabled
    public static String deletePlacements(List<Placement_Content__c> list_Contents){
        Set<Id> ids = new Set<Id>();
        List<Placement_Content__c> list_ValidContents = new List<Placement_Content__c>();
        for(Placement_Content__c content : list_Contents){
            if(content.Id != null) {
                ids.add(content.Id);
                list_ValidContents.add(content);
            }
        }
        
        // get all ABTest and Take Down records
        for(Placement_Content__c abOrTakeown : [SELECT id,name,Parent_Content__c FROM Placement_Content__c WHERE Parent_Content__c in:ids])
        {
            ids.add(abOrTakeown.Parent_Content__c);
            list_ValidContents.add(abOrTakeown);
        }
        
        //get All Detail Records for deleting
        list<Placement_Content_Detail__c> list_Details = [SELECT id,name FROM Placement_Content_Detail__c WHERE Placement_Content__c in:ids];
        
        if(list_Details.size() > 0) delete list_Details;
        if(list_ValidContents.size() > 0) delete list_ValidContents;
        
        return 'Success';
    }
    
    public class DGTL_MultiContentDeleteWrapper{
        
        @AuraEnabled public List<Placement_Content__c> list_Contents {get;set;}
        @AuraEnabled public List<Placement_Content__c> list_LockedContents {get;set;}
        @AuraEnabled public List<Placement_Content__c> list_nonControlled {get;set;}       
        
        public DGTL_MultiContentDeleteWrapper(){
            list_Contents = new List<Placement_Content__c>();
            list_LockedContents = new List<Placement_Content__c>();
            list_nonControlled = new List<Placement_Content__c>();
        }
    }
    
}
