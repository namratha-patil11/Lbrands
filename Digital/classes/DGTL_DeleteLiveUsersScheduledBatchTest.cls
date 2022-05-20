/************************************************************
Name          : DGTL_DeleteLiveUsersScheduledBatchTest
Description   : Test Class for DGTL_DeleteLiveUsersScheduledBatch      
*************************************************************/
@isTest
private class DGTL_DeleteLiveUsersScheduledBatchTest {

	private static testMethod void Scheduletest() {
	    Test.StartTest();
        DGTL_DeleteLiveUsersScheduledBatch sh1 = new DGTL_DeleteLiveUsersScheduledBatch();
        String sch = '0 0 23 * * ?'; system.schedule('Test DGTL_DeleteLiveUsersScheduledBatch', sch, sh1);
        Test.stopTest();
	}

}