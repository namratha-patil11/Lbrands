public class DGTL_DayViewController {
	
    @AuraEnabled
    public static Id getTaskId(String floorsetPlanId){
        Id taskId;
        try{
            taskId = [SELECT Id FROM DGTL_Task__c WHERE RecordType.DeveloperName='Day_View' AND Floorset_Plan__c = :floorsetPlanId LIMIT 1].Id;
        }catch(Exception e){
            if(!Test.isRunningTest())
            throw new AuraException('No Records Found!');
        }
        return taskId;
    }
}