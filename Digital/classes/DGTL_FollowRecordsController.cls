public class DGTL_FollowRecordsController { 
    
    @AuraEnabled
    public static DGTL_WrapperClasses.FollowDetails isFeedEnabled(String objName, String recId){
        DGTL_WrapperClasses.FollowDetails follwDet = new DGTL_WrapperClasses.FollowDetails();
        try{
            String[] types = new String[]{objName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            follwDet.isFeedEnabled = results[0].isFeedEnabled();
            follwDet.isFollowed = follwDet.isFeedEnabled ? isRecFollowed(recId) : follwDet.isFollowed;
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        
        return follwDet;
        
    }
    
    private static Boolean isRecFollowed(String recId){
        Boolean followed = false;
        try{
            EntitySubscription entSubs = [SELECT Id FROM EntitySubscription 
                                          WHERE SubscriberId = :UserInfo.getUserId() 
                                          AND ParentId = :recId LIMIT 1];
            followed = true;
        }catch(QueryException qe){
            System.debug('Exception caught : '+qe.getMessage());
        }
        
        return followed;
    }
    
    @AuraEnabled
    public static void setSubscription(String recId, Boolean follow){
        
        try{
            if(follow){
                subscribe(recId);
            }else{
                unsubscribe(recId);
            }
        }catch(Exception e){
            throw new AuraException(e.getMessage());
        }
        
    }
    
    private static void subscribe(String recId){
        EntitySubscription e = new EntitySubscription();
        e.subscriberId = UserInfo.getUserId();
        e.parentId = recId;
        insert e;
    }
    
    private static void unsubscribe(String recId){
        DELETE[SELECT Id FROM EntitySubscription 
               WHERE SubscriberId = :UserInfo.getUserId() 
               AND parentId = :recId LIMIT 1];
    }
    
    

}