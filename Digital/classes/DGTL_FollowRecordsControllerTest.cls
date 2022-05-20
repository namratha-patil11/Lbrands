@isTest
public class DGTL_FollowRecordsControllerTest {
	
    public static testMethod void testFollow(){
        Account acc = new Account(Name='abc');
        insert acc;
        DGTL_FollowRecordsController.isFeedEnabled('Account','abc');
        DGTL_FollowRecordsController.setSubscription(acc.Id,false);
        DGTL_FollowRecordsController.setSubscription(acc.Id,true);
    }
}