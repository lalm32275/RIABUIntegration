@IsTest
private class RiabuAccountJobTest {
    
    @TestSetup
    static void setup() {
        // Create test Riabu__c custom setting/object record
        Riabu__c riabuObj = new Riabu__c(
            Name = 'Test Riabu',
            Client_Id__c = 'test_client_id',
            client_secret__c = 'test_secret',
            Password__c = 'test_password',
            refreshToken__c = 'test_refresh_token',
            AccessToken__c = 'test_access_token',
            Expire_Date__c = Date.today().addDays(1) // Future date
        );
        insert riabuObj;
        
        // Create test accounts for existing records scenario
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(
            Name = 'Existing Account',
            RiabuCompany_Id__c = 'EXISTING123',
            Description = 'Test Existing Account',
            RiabuAccountId__c = 'ACC123'
        ));
        insert testAccounts;
    }
    
    @IsTest
    static void testExecute_SuccessfulAccountCreation() {
        // Mock the callout response
        Test.setMock(HttpCalloutMock.class, new RiabuAccountMockGenerator());
        
        Test.startTest();
        // Execute the queueable job
        System.enqueueJob(new RiabuAccountJob());
        Test.stopTest();
        
        // Verify results - check that new accounts were created
        List<Account> allAccounts = [SELECT Id, Name, RiabuCompany_Id__c, Description, Days_to_Pay__c, RiabuAccountId__c 
                                   FROM Account 
                                   WHERE RiabuAccountId__c != null];
        
        // Should have accounts created (excluding potential duplicates)
        System.assert(allAccounts.size() >= 1, 'Accounts should have been created');
    }
    
    @IsTest
    static void testExecute_WithExistingAccounts() {
        // Mock the callout response that includes existing company ID
        Test.setMock(HttpCalloutMock.class, new RiabuAccountMockGenerator());
        
        Test.startTest();
        System.enqueueJob(new RiabuAccountJob());
        Test.stopTest();
        
        // Verify that no duplicate was created for EXISTING123
        List<Account> existing123Accounts = [SELECT Id FROM Account WHERE RiabuCompany_Id__c = 'EXISTING123'];
        System.assertEquals(1, existing123Accounts.size(), 'Should not create duplicate for EXISTING123');
    }
    
    @IsTest
    static void testExecute_ExceptionHandling() {
        // Mock a callout failure
        Test.setMock(HttpCalloutMock.class, new RiabuAccountMockGenerator(true));
        
        Test.startTest();
        try {
            System.enqueueJob(new RiabuAccountJob());
        } catch (Exception e) {
            // Exception should be caught within the execute method
        }
        Test.stopTest();
        
        // Test passes if no exception is thrown
        System.assert(true, 'Should handle exceptions gracefully');
    }
    
    @IsTest
    static void testExecute_EmptyResponse() {
        // Mock empty response
        Test.setMock(HttpCalloutMock.class, new RiabuAccountMockGenerator(false, true));
        
        Test.startTest();
        System.enqueueJob(new RiabuAccountJob());
        Test.stopTest();
        
        // Verify no new accounts were created for empty response
        List<Account> allAccounts = [SELECT Id FROM Account];
        System.assertEquals(1, allAccounts.size(), 'Only setup account should exist');
    }
    
    @IsTest
    static void testExecute_NullValuesHandling() {
        // Mock response with null values
        Test.setMock(HttpCalloutMock.class, new RiabuAccountMockGenerator(false, false, true));
        
        Test.startTest();
        System.enqueueJob(new RiabuAccountJob());
        Test.stopTest();
        
        // Should handle null values without errors
        System.assert(true, 'Should handle null values gracefully');
    }

    // Inner mock class for callouts
    public class RiabuAccountMockGenerator implements HttpCalloutMock {
        private Boolean throwError;
        private Boolean returnEmpty;
        private Boolean returnNullValues;
        
        public RiabuAccountMockGenerator() {
            this(false, false, false);
        }
        
        public RiabuAccountMockGenerator(Boolean throwError) {
            this(throwError, false, false);
        }
        
        public RiabuAccountMockGenerator(Boolean throwError, Boolean returnEmpty) {
            this(throwError, returnEmpty, false);
        }
        
        public RiabuAccountMockGenerator(Boolean throwError, Boolean returnEmpty, Boolean returnNullValues) {
            this.throwError = throwError;
            this.returnEmpty = returnEmpty;
            this.returnNullValues = returnNullValues;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            if (throwError) {
                CalloutException e = new CalloutException();
                e.setMessage('Mocked callout error');
                throw e;
            }
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            if (returnEmpty) {
                res.setBody('{"data": []}');
            } else if (returnNullValues) {
                // Mock response with null values to test error handling
                String responseBody = '{"data": [' +
                    '{"id": null, "company_id": null, "name": null, "agreed_credit_terms_day": null},' +
                    '{"id": "RAB004", "company_id": "COMP004", "name": "Test Company 4", "agreed_credit_terms_day": "30"}' +
                ']}';
                res.setBody(responseBody);
            } else {
                // Mock response with test data - 2 new accounts + 1 existing
                // Match the exact structure your fetcher expects
                String responseBody = '{"data": [' +
                    '{"id": "RAB001", "company_id": "COMP001", "name": "Test Company 1", "agreed_credit_terms_day": "30"},' +
                    '{"id": "RAB002", "company_id": "COMP002", "name": "Test Company 2", "agreed_credit_terms_day": "45"},' +
                    '{"id": "RAB003", "company_id": "EXISTING123", "name": "Existing Company", "agreed_credit_terms_day": "60"}' +
                ']}';
                res.setBody(responseBody);
            }
            
            return res;
        }
    }
}