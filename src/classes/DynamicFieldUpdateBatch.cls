/**
 * Created by Chris Fellows on 1/9/18 for Atlassian.
 * 
 * Purpose: Provide easy update of a field on an object depending on the value of another field. Ex. If can update 
 * Account.Enterprise_Account_Status__c = Gold if Gold_Account__c = true. Can handle any number of records and is 
 * dyanmic to any object and any field.
 */
global class DynamicFieldUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private static Dynamic_Batch__mdt dynamicBatch = 
            [SELECT Field_To_Be_Updated__c, Object_To_Be_Updated__c, Where_Clause__c, New_Value__c, Email_Address__c 
               FROM Dynamic_Batch__mdt 
              WHERE DeveloperName = 'Default_Run_Config'];
    
    public String fieldToBeUpdated = dynamicBatch.Field_To_Be_Updated__c;
    public String objectToBeUpdated = dynamicBatch.Object_To_Be_Updated__c;
    public String newValue = dynamicBatch.New_Value__c;
    public String whereClause = dynamicBatch.Where_Clause__c;
    public String emailAddress = dynamicBatch.Email_Address__c;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ' + fieldToBeUpdated + 
                        ' FROM '+ objectToBeUpdated +
                        ' WHERE '+ whereClause;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) { 
        
        List<sObject> sobjList = new List<sObject>();

        for(sobject sobj : scope) {
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectToBeUpdated);
            Schema.DescribeSObjectResult r = t.getDescribe();
            Schema.DescribeFieldResult f = r.fields.getMap().get(fieldToBeUpdated).getDescribe();

            if (f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.picklist) {
                sobj.put(fieldToBeUpdated, newValue);
            }
            else if(f.getType() == Schema.DisplayType.Boolean) {
                // @TODO implement other types as needed
                sobj.put(fieldToBeUpdated, null);
            }
            else {
                sobj.put(fieldToBeUpdated, null);
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        if(!Test.isRunningTest()) {
            AsyncApexJob a = 
                [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                   FROM AsyncApexJob 
                  WHERE Id = :bc.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{
                    emailAddress
            });
            mail.setReplyTo(emailAddress);
            mail.setSenderDisplayName('SFDC Sys Admin');
            mail.setSubject('Dynamic Batch Process Completed on ' +
                    objectToBeUpdated + '.' + fieldToBeUpdated);
            mail.setPlainTextBody('Batch Process has completed on ' +
                    objectToBeUpdated + '.' + fieldToBeUpdated + ', with status: ' + a.Status + ', items processed: ' +
                    a.TotalJobItems + ' batches with errors: ' + a.NumberOfErrors);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }
    }
}