@IsTest
public class RiabuAccountMockGenerator implements HttpCalloutMock {
    private Boolean throwError;
    private Boolean returnEmpty;
    
    public RiabuAccountMockGenerator() {
        this(false, false);
    }
    
    public RiabuAccountMockGenerator(Boolean throwError) {
        this(throwError, false);
    }
    
    public RiabuAccountMockGenerator(Boolean throwError, Boolean returnEmpty) {
        this.throwError = throwError;
        this.returnEmpty = returnEmpty;
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
            res.setBody('[]');
        } else {
            // Mock response with test data
            String responseBody = '[' +
                '{"id": "RAB001", "company_id": "COMP001", "name": "Test Company 1", "agreed_credit_terms_day": "30"},' +
                '{"id": "RAB002", "company_id": "COMP002", "name": "Test Company 2", "agreed_credit_terms_day": "45"},' +
                '{"id": "RAB003", "company_id": "EXISTING123", "name": "Existing Company", "agreed_credit_terms_day": "60"}' +
            ']';
            res.setBody(responseBody);
        }
        
        return res;
    }
}