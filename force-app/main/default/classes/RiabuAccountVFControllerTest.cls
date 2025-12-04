@isTest
private class RiabuAccountVFControllerTest {

    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Boolean returnSuccess;
        private Boolean returnEmpty;
        
        public MockHttpResponseGenerator(Boolean returnSuccess, Boolean returnEmpty) {
            this.returnSuccess = returnSuccess;
            this.returnEmpty = returnEmpty;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (returnSuccess) {
                res.setStatusCode(200);
                if (returnEmpty) {
                    res.setBody('{"data": []}');
                } else {
                    res.setBody('{"data": [{"id": "RIABU001", "company_id": "MOCK001", "name": "Test Company", "agreed_credit_terms_day": "15"}]}');
                }
            } else {
                res.setStatusCode(400);
                res.setBody('{"error": "Bad Request"}');
            }
            return res;
        }
    }

    // Setup test data
    @TestSetup
    static void setupTestData() {
        Riabu__c riabuObj = new Riabu__c();
        riabuObj.Name = 'Test Riabu';
        riabuObj.Client_Id__c = 'test-client-id';
        riabuObj.client_secret__c = 'test-secret';
        riabuObj.Password__c = 'test-password';
        riabuObj.refreshToken__c = 'test-refresh-token';
        riabuObj.AccessToken__c = 'test-access-token';
        riabuObj.Expire_Date__c = Date.today().addDays(1);
        insert riabuObj;
    }

    // Test constructor
    @isTest
    static void testConstructor() {
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        Test.stopTest();
        
        System.assertEquals('Wait, we are checking the server...', controller.message);
    }

    // Test successful account insertion with mock data
    @isTest
    static void testInsertAccounts_success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true, false));
        
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertAccounts();
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, Name, RiabuCompany_Id__c, RiabuAccountId__c, Days_to_Pay__c FROM Account];
        System.assertEquals(1, accounts.size(), 'One account should be inserted');
        System.assert(controller.message.contains('Account(s) inserted successfully!'), 'Success message should be shown');
    }

    // Test no new records scenario
    @isTest
    static void testInsertAccounts_noNewRecords() {
        Account existingAcc = new Account();
        existingAcc.Name = 'Existing Company';
        existingAcc.RiabuCompany_Id__c = 'MOCK001';
        existingAcc.RiabuAccountId__c = 'RIABU001';
        insert existingAcc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true, false));
        
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertAccounts();
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account WHERE RiabuCompany_Id__c = 'MOCK001'];
        System.assertEquals(1, accounts.size(), 'Should not create duplicate account');
        System.assert(controller.message.contains('No new records to insert.'), 'No new records message should be shown');
    }

    // Test empty response from API
    @isTest
    static void testInsertAccounts_emptyResponse() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true, true));
        
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertAccounts();
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(0, accounts.size(), 'No accounts should be inserted with empty response');
        System.assert(controller.message.contains('No new records to insert.'), 'No new records message should be shown');
    }

    // Test API failure scenario
    @isTest
    static void testInsertAccounts_apiFailure() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false, false));
        
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertAccounts();
        Test.stopTest();
        
        System.assert(controller.message.contains('Error during insert:'), 'Error message should be shown for API failure');
    }

    // Test batch method - insertOthers
    @isTest
    static void testInsertOthers() {
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertOthers();
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE ApexClass.Name = 'RiabuAccountDataFetcherClass'];
        System.assertEquals(1, jobs.size(), 'Batch job should be scheduled');
    }

    // Test batch method - insertOrdersAndChatters
    @isTest
    static void testInsertOrdersAndChatters() {
        Test.startTest();
        RiabuAccountVFController controller = new RiabuAccountVFController();
        controller.insertOrdersAndChatters();
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, ApexClass.Name, Status FROM AsyncApexJob WHERE ApexClass.Name = 'RiabuGetOrderAndChatterBatch'];
        System.assertEquals(1, jobs.size(), 'Batch job should be scheduled');
    }
}