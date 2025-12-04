@IsTest
public class RiabuAccountFetcherTest {
    
    @IsTest
    static void testFetchAccounts() {
        // Create Riabu setting
        Riabu__c riabuSetting = new Riabu__c(
            Name = 'Test',
            AccessToken__c = 'test_token',
            Expire_Date__c = Date.today().addDays(1)
        );
        insert riabuSetting;
        
        // Set mock
        Test.setMock(HttpCalloutMock.class, new MockFetcher());
        
        Test.startTest();
        List<Map<String, Object>> result = RiabuAccountFetcher.fetchAccountsFromRiabu();
        Test.stopTest();
        
        System.assert(result != null, 'Should return data');
    }
    
    public class MockFetcher implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"data": [{"id": "1", "company_id": "COMP1", "name": "Test Company"}]}');
            return res;
        }
    }
}