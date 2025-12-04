@isTest
private class RiabuAuthTokenUtilTest {

    // Custom mock class to simulate the HTTP callout response
    private class RiabuAuthMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Simulated token response
            String responseBody = JSON.serialize(new Map<String, Object>{
                'access_token' => 'mock_access_token_123',
                'refresh_token' => 'mock_refresh_token_456',
                'expires_in' => 3600
            });
            res.setBody(responseBody);
            return res;
        }
    }

    @isTest
    static void testGetAccessToken_success() {
        // Create test Riabu__c record
        Riabu__c testRiabu = new Riabu__c(
            Name = 'testuser@example.com',
            Client_Id__c = 'test_client_id',
            client_secret__c = 'test_client_secret',
            Password__c = 'test_password'
        );
        insert testRiabu;

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new RiabuAuthMockResponse());

        // Start test context
        Test.startTest();
        RiabuAuthTokenUtil.getAccessToken();
        Test.stopTest();

        // Retrieve updated record
        Riabu__c updatedRiabu = [SELECT AccessToken__c, refreshToken__c, Expire_Date__c FROM Riabu__c WHERE Id = :testRiabu.Id];

        // Assert values were set
        System.assertEquals('mock_access_token_123', updatedRiabu.AccessToken__c);
        System.assertEquals('mock_refresh_token_456', updatedRiabu.refreshToken__c);
        System.assertNotEquals(null, updatedRiabu.Expire_Date__c);
        System.assert(updatedRiabu.Expire_Date__c > System.now(), 'Expire_Date__c should be in the future');
    }
}