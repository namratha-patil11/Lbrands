/* Name        : DGTL_InboundEmailEscalationTask
 * Description : This class is used to implements Messaging.InboundEmailHandler
 * Author      : Vidya Sagar 
 */
global class DGTL_InboundEmailEscalationTask implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            String emailBody = email.plainTextBody.toLowerCase();
            string statusUpdate = emailBody.substring(0,30);
            String taskId = email.plainTextBody.substringAfter('%%~~');
            // get task id
            if(taskId.contains('['))
            {
                taskId = taskId.substringBefore('[');
            }
            system.debug('--taskId--'+taskId+'-'+email.fromAddress);
            String str_Approved = 'approved';
            String str_Rejected = 'rejected';
            // get task details
            DGTL_Task__c obj_Task = [select Id,Name,Status__c,DGTL_TaskOwner__c,Brand__c,Placement_Content__r.Name,lastmodifiedby.Name from DGTL_Task__c where Id=:taskId];
            // get user id form email
            string userid = [select id from User where Email=:email.fromAddress].Id;
            // check task status 
            if(obj_Task.Status__c !='Approved' && obj_Task.Status__c !='Rejected'){
                User modifiedUser = [select id,Name from User where Email=:email.fromAddress];
            list<Id> list_userIds = new list<Id>(); 
            string groupname = obj_Task.Brand__c+'-Escalation Queue';
            list_userIds = DGTL_DataAccessor.getPublicGroupMembers(new set<string>{groupname}).get(groupname);
            // checks for invalid/blank status 
            if(!statusUpdate.contains(str_Approved) && !statusUpdate.contains(str_Rejected)){  
                // send email for invalid status
                sendMail(new list<string>{userid},email.subject,'This is Not valid status, please provide valid status',email.messageId);
            }else if(!list_userIds.isEmpty()){
                // get email template and replace values
                EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName ='DGTL_Escalation_Update_Email'];
                string strBody = emailTemplate.Body;
                string strSubject = emailTemplate.Subject;
                strBody = strBody.replace('{!statususer}', modifiedUser.Name);
                strBody = strBody.replace('{!placementname}', obj_Task.Placement_Content__r.Name);
                string baseUrl = string.valueof(url.getSalesforceBaseUrl());
                baseUrl = baseUrl.substringAfter('delegate=');
                baseUrl = baseUrl.remove(']');
                strBody = strBody.replace('{!taskId}',baseUrl +'/'+obj_Task.Id);
                // check for approved or rejected and update status of task
                if(statusUpdate.contains(str_Approved)){                    
                    obj_Task.Status__c = 'Approved';                    
                    update obj_Task;
                    strSubject = strSubject.replace('{!status}', 'Approved');
                    strBody = strBody.replace('{!status}', 'Approved');
                    sendMail(list_userIds,strSubject,strBody,''); 
                }else if(statusUpdate.contains(str_Rejected)){                    
                    obj_Task.Status__c = 'Rejected';
                    update obj_Task;
                    strSubject = strSubject.replace('{!status}', 'Rejected');
                    strBody = strBody.replace('{!status}', 'Rejected');
                    sendMail(list_userIds,strSubject,strBody,''); 
                }
            }
            }else{
                // if task has already approved/rejected send email notification 
                sendMail(new list<string>{userid},email.subject,'This Content has been already '+obj_Task.Status__c+' by '+obj_Task.lastmodifiedby.Name,email.messageId);
            }
            result.success = true;
        }catch(exception ex ){
            system.debug('--inbound email exception-'+ex.getLineNumber()+ex.getMessage());
            result.message = 'please contact to team salesforce  ' + ex.getMessage();
        }        
        return result;
    }
    
    /**
    * @description	This Method is used to send email
    * @param		toAddress - list user id, subject - subject of email,emailBody - body of email,messageId - message id
    * @return       Map - key- layout id, value - collection page name
    */
    public void sendMail(list<Id> toAddress,string subject,string emailBody,string messageId) {
        List<Messaging.SingleEmailMessage> list_emails = new List<Messaging.SingleEmailMessage>();
        for(Id usrid :toAddress){
            Messaging.SingleEmailMessage  email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(usrid);
            email.SaveAsActivity = false;
            if(string.isNotBlank(messageId)){
                email.setReferences(messageId);
                email.setSubject(subject);
                email.setPlainTextBody(emailBody);
            }else{
                email.setSubject(subject);
                email.setPlainTextBody(emailBody);
            }
            list_emails.add(email);
            
        }
        if(list_emails.size() > 0 ) Messaging.sendEmail(list_emails); 
        
    }    
    
}