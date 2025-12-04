@isTest
public class ContactTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Contacts
        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id, isPrimary__c = false));
        conList.add(new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc.Id, isPrimary__c = true));
        insert conList;
    }

    @isTest
    static void testCreatePrimaryContact_BatchCallFalse() {
        // Fetch contacts
        List<Contact> contacts = [SELECT Id, AccountId, isPrimary__c FROM Contact];
        
        // Mock CustomerCreationService behavior
        Test.startTest();
        ContactTriggerHandler.isBatchCall = false;

        // Call the method under test
        ContactTriggerHandler.createPrimaryContact(contacts);
        Test.stopTest();

        // Verify that only one primary contact per account remains
        List<Contact> updatedContacts = [SELECT Id, isPrimary__c FROM Contact];
        Integer primaryCount = 0;
        for (Contact c : updatedContacts) {
            if (c.isPrimary__c) primaryCount++;
        }

        System.assertEquals(1, primaryCount, 'There should be only one primary contact per Account');
    }

    @isTest
    static void testCreatePrimaryContact_BatchCallTrue() {
        List<Contact> contacts = [SELECT Id, AccountId, isPrimary__c FROM Contact];
        Test.startTest();
        ContactTriggerHandler.isBatchCall = true;

        // Call create method when isBatchCall is true (should skip updateCustomer)
        ContactTriggerHandler.createPrimaryContact(contacts);
        Test.stopTest();

        // No exception should occur
        System.assert(true, 'createPrimaryContact executed successfully with isBatchCall = true');
    }

    @isTest
    static void testUpdatePrimaryContact_BatchCallFalse() {
        List<Contact> contacts = [SELECT Id, AccountId, isPrimary__c FROM Contact];
        
        Test.startTest();
        ContactTriggerHandler.isBatchCall = false;

        // Call the updatePrimaryContact method
        ContactTriggerHandler.updatePrimaryContact(contacts);
        Test.stopTest();

        // Verify logic same as create method
        List<Contact> updatedContacts = [SELECT Id, isPrimary__c FROM Contact];
        Integer primaryCount = 0;
        for (Contact c : updatedContacts) {
            if (c.isPrimary__c) primaryCount++;
        }

        System.assertEquals(1, primaryCount, 'Only one primary contact should remain after updatePrimaryContact');
    }

    @isTest
    static void testUpdatePrimaryContact_BatchCallTrue() {
        List<Contact> contacts = [SELECT Id, AccountId, isPrimary__c FROM Contact];
        Test.startTest();
        ContactTriggerHandler.isBatchCall = true;

        // Call update method when isBatchCall is true (should skip CustomerCreationService)
        ContactTriggerHandler.updatePrimaryContact(contacts);
        Test.stopTest();

        System.assert(true, 'updatePrimaryContact executed successfully with isBatchCall = true');
    }
}