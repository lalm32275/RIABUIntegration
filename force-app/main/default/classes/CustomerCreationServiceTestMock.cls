public class CustomerCreationServiceTestMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        res.setBody('{"success": true, "data": {"calls": {"items": [{"id": 201, "person": "John Doe", "assigned_discrepancy_manager": "Jane Smith", "assigned_discrepancy_supervisor": "Robert Brown", "assigned_gm_ceo": "Alice White", "invoice_number": "INV-98765", "invoice_amount": "15000.00"}]}}}');       
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
}