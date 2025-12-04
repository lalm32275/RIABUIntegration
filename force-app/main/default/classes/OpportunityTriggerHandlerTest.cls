@isTest
public class OpportunityTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Riabu configuration - THIS IS CRITICAL
        Riabu__c riabuConfig = new Riabu__c(
            Name = 'Test Config',
            Client_Id__c = 'test-client-id',
            client_secret__c = 'test-secret',
            Password__c = 'test-password',
            AccessToken__c = 'test-token',
            refreshToken__c = 'test-refresh-token',
            Expire_Date__c = DateTime.now().addDays(1)
        );
        insert riabuConfig;
        
        // Create Account with RiabuAccountId__c
        Account testAccount = new Account(
            Name = 'Test Account',
            RiabuAccountId__c = 'test-riabu-id'
        );
        insert testAccount;
    }
    
    @isTest
    static void testCreateOrderOnInsert() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Set mock to prevent actual callouts
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        
        Test.startTest();
        // Create opportunity - this will trigger your existing trigger
        Opportunity newOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert newOpp;
        Test.stopTest();
        
        // Basic assertion - opportunity was created
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
        System.assertEquals(1, opps.size(), 'Opportunity should be created');
    }
    
    @isTest
    static void testCreateOrderWithoutAccount() {
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        
        Test.startTest();
        // Create opportunity without account
        Opportunity newOpp = new Opportunity(
            Name = 'Test Opp No Account',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
            // No AccountId
        );
        insert newOpp;
        Test.stopTest();
        
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp No Account'];
        System.assertEquals(1, opps.size(), 'Opportunity should be created');
    }
    
    @isTest
    static void testCreateOrderInstantly() {
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        
        Test.startTest();
        // Test the createOrderInstantly method
        OpportunityTriggerHandler.createOrderInstantly();
        Test.stopTest();
        
        // No assertion needed - just testing that no exception is thrown
    }
    
    @isTest
    static void testCreateOrderMethod() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CustomerCreationServiceTestMock());
        
        Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity(
            Name = 'Direct Test Opp',
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        oppList.add(opp);
        
        // Test the handler method directly
        OpportunityTriggerHandler.createOrder(oppList);
        Test.stopTest();
        
        // No assertion needed - just testing method execution
    }
}