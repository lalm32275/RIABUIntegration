@IsTest
public class RiabuCustomerServiceTest {
    
    @IsTest
    static void testFetchAndCreateAccounts() {
        // Create test accounts for the StandardSetController
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert testAccounts;
        
        // Create StandardSetController with test accounts
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(testAccounts);
        stdController.setSelected(testAccounts);
        
        // Create service instance
        RiabuCustomerService service = new RiabuCustomerService(stdController);
        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        
        Test.startTest();
        PageReference result = service.fetchAndCreateAccounts();
        Test.stopTest();
        
        // Verify the method executed
        System.assert(result == null, 'Should return null PageReference');
    }
    
    @IsTest
    static void testConstructor() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account')
        };
        insert testAccounts;
        
        // Create StandardSetController
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(testAccounts);
        stdController.setSelected(testAccounts);
        
        Test.startTest();
        RiabuCustomerService service = new RiabuCustomerService(stdController);
        Test.stopTest();
        
        // Verify constructor works
        System.assert(service != null, 'Service should be created');
    }
    
    @IsTest
    static void testFetchAndCreateAccountsEmptyResponse() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account')
        };
        insert testAccounts;
        
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(testAccounts);
        stdController.setSelected(testAccounts);
        
        RiabuCustomerService service = new RiabuCustomerService(stdController);
        
        // Set mock for empty response
        Test.setMock(HttpCalloutMock.class, new MockEmptyResponseGenerator());
        
        Test.startTest();
        PageReference result = service.fetchAndCreateAccounts();
        Test.stopTest();
        
        System.assert(result == null, 'Should return null PageReference');
    }
    
    public class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"success": true, "data": [{"id": 1, "company_id": "COMP001", "name": "Test Company", "acronym": "TC", "agreed_credit_terms_day": 30, "is_hidden": 0, "percentage": 85}]}');
            return res;
        }
    }
    
    public class MockEmptyResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"success": true, "data": []}');
            return res;
        }
    }
}