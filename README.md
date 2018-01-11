# README #

Atlassian Code Test

### What is this repository for? ###

* Code sharing for Atlassian coding challenge

### How do I get set up? ###

* Download code
* Setup a sandbox
* Enable Mass Email if you want to receive a notification email
* Run "ant deployCode" from the command line.

### How run batch job? ###

Batch job configuration details are stored in Custom Metadata called Dynamic Batch Job. 
There is a record called Default Run Config. Edit the values of this record to specify:

* The field to be modified, e.g. Enterprise_Account_Status__c
* The object to be modified, e.g. TestAccount__c
* The where clause to determine under what conditions should the field be modified, e.g. WHERE RecordTypeId = XXXXXXX
* The new value for the field to be modified, e.g. Bronze
* The email address to send details about the batch job on completion, e.g. you@yourdomain.com

After these details have been saved you can run the batch job like any other batch job via Anonymous Apex.


        DynamicFieldUpdateBatch batchClass = new DynamicFieldUpdateBatch();
        DataBase.executeBatch(batchClass, 200);

If you'd like to replicate the problem exactly, you will need the Id of the Customer RecordTypeId. 
You can return that with the following code.

        Id customerRecordTypeId = 
            Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        System.debug('ID: ' + customerRecordTypeId);  

Note: you also have the option to set the values of the job programmatically like so:

        DynamicFieldUpdateBatch batchClass = new DynamicFieldUpdateBatch();
        batchClass.fieldToBeUpdated = 'Enterprise_Account_Status__c';
        batchClass.objectToBeUpdated = 'TestAccount__c';
        batchClass.newValue = 'Bronze';
        batchClass.emailAddress = 'chrisfellows@zencloudtech.com';
        batchClass.whereClause = 'Enterprise_Account_Status__c = null AND RecordTypeId = \'' + Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId() + '\'';
        DataBase.executeBatch(batchClass, 200);
        
### How to verify batch job? ###

I suggest using the following code to verify.

Initialize test records in Anonymous Apex:

    static Id customerRecordTypeId =
    Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id clientRecordTypeId =
    Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
    TestAccount__c customerAccount1 = new TestAccount__c();
    customerAccount1.RecordTypeId = customerRecordTypeId;
    customerAccount1.Enterprise_Account_Status__c = null;
    TestAccount__c customerAccount2 = new TestAccount__c();
    customerAccount2.RecordTypeId = customerRecordTypeId;
    customerAccount2.Enterprise_Account_Status__c = 'Bronze';
    TestAccount__c clientAccount = new TestAccount__c();
    clientAccount.RecordTypeId = clientRecordTypeId;
    clientAccount.Status__c = null;
    clientAccount.Enterprise_Account_Status__c = null;
    insert new List<TestAccount__c>{customerAccount1, customerAccount2, clientAccount};

Then run SOQL:

    SELECT Id, Enterprise_Account_Status__c, RecordTypeId 
      FROM TestAccount__c

Then run the batch job and execute the SOQL again to verify the values are updated accordingly.

If necessary, delete the records and run again with different value sets.

    List <TestAccount__c> taList = [SELECT Id FROM TestAccount__c];
    delete taList;


### Who do I talk to? ###

* Chris Fellows
* chrisfellows@zencloudtech.com
* 914.772.3847