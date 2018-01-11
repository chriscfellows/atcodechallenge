/**
 * Created by Chris Fellows on 1/9/18 for Atlassian.
 * 
 * Purpose: To test DynamicFieldUpdateBatch.
 */
@isTest
public with sharing class DynamicFieldUpdateBatchTest {
    
    static Id customerRecordTypeId = 
            Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id clientRecordTypeId = 
            Schema.SObjectType.TestAccount__c.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
    
    @testSetup
    static void setupTests() {
        
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
    }
    
    @isTest
    static void whenValueIsNullThenSuccess() {

        List<TestAccount__c> accounts = 
                [SELECT Id, Status__c, Enterprise_Account_Status__c FROM TestAccount__c 
                  WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        System.assertEquals(1, accounts.size());
        Test.startTest();
        DynamicFieldUpdateBatch batchClass = new DynamicFieldUpdateBatch();
        batchClass.fieldToBeUpdated = 'Enterprise_Account_Status__c'; 
        batchClass.objectToBeUpdated = 'TestAccount__c';
        batchClass.newValue = 'Bronze';
        batchClass.emailAddress = 'chrisfellows@zencloudtech.com';
        batchClass.whereClause = 'Enterprise_Account_Status__c = null';
        DataBase.executeBatch(batchClass, 200);
        Test.stopTest();
        accounts =
                [SELECT Id, Status__c, Enterprise_Account_Status__c FROM TestAccount__c
                  WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        System.assertEquals(2, accounts.size());
    }
    
    @isTest
    static void loadTest() {

        List<TestAccount__c> accounts = new List<TestAccount__c>();

        Integer numOfAccounts =
            [SELECT COUNT() FROM TestAccount__c
              WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        System.assertEquals(1, numOfAccounts);
        
        for(Integer i = 0; i < 40; i++) {
            TestAccount__c obj = new TestAccount__c();
            obj.RecordTypeId = customerRecordTypeId;
            obj.Enterprise_Account_Status__c = null;
            accounts.add(obj);
        }
        for(Integer i = 0; i < 10; i++) {
            TestAccount__c obj = new TestAccount__c();
            obj.RecordTypeId = clientRecordTypeId;
            obj.Enterprise_Account_Status__c = null;
            accounts.add(obj);
        }
        for(Integer i = 0; i < 40; i++) {
            TestAccount__c obj = new TestAccount__c();
            obj.RecordTypeId = customerRecordTypeId;
            obj.Enterprise_Account_Status__c = 'Bronze';
            accounts.add(obj);
        }
        insert accounts;
        
        numOfAccounts =
            [SELECT COUNT() FROM TestAccount__c
              WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        System.assertEquals(41, numOfAccounts);
        
        Test.startTest();
        DynamicFieldUpdateBatch batchClass = new DynamicFieldUpdateBatch();
        batchClass.fieldToBeUpdated = 'Enterprise_Account_Status__c';
        batchClass.objectToBeUpdated = 'TestAccount__c';
        batchClass.newValue = 'Bronze';
        batchClass.emailAddress = 'chrisfellows@zencloudtech.com';
        batchClass.whereClause = 'Enterprise_Account_Status__c = null';
        DataBase.executeBatch(batchClass, 200);
        Test.stopTest();
        
        numOfAccounts =
            [SELECT COUNT() FROM TestAccount__c
              WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        numOfAccounts =
        [SELECT COUNT() FROM TestAccount__c
        WHERE Enterprise_Account_Status__c = 'Bronze' and RecordTypeId = :customerRecordTypeId];
        System.assertEquals(82, numOfAccounts);
    }
}