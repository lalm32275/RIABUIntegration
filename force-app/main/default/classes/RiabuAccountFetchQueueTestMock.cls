public class RiabuAccountFetchQueueTestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(
            '{"data":[{"name":"Riabu Pte Ltd","id":1001,"company_id":"C-2025-001","agreed_credit_terms_day":30}]}'
        );
        return res;
    }
}