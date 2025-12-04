public class RiabuAccountDataFetcherTestMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
            if ( req.getEndPoint().contains('/master-file/view/' ) ){
                         res.setBody('{"success": true,"data": {"company_name": "Riabu Pte Ltd","claim_name": "Claim123","model": {"id": 1001,"user_id": 501,"company_id": "C-2025-001","customer_since": "2022-05-10","agreed_credit_terms_day": 30,"procurement_portal": "Coupa","accounts_payable_contact_name": "John Doe","accounts_payable_email_address": "accounts@riabu.com","accounts_payable_phone_number": "9876543210","accounts_payable_phone_code": "+65","email_to_send_e_invoices_to": "invoices@riabu.com","special_instructions": 0,"instructions": "Please send all invoices by the 1st of each month.","other_emails": "finance@riabu.com","file": "agreement.pdf","created_at": "2022-05-10T10:00:00Z","updated_at": "2023-08-01T12:00:00Z","colleagues_email": "team@riabu.com","file_old_name": "old_agreement.pdf","credit_policy_as_at": "2023-01-01","hidden": 0,"claim_id": 999,"high_risk_customer": false,"has_customer_signed": 1,"reason_has_not_signed": null,"company": {"company_id": 1001,"id": "COMP-1001","name": "Riabu Pte Ltd","uen": "202512345A","uen_status": "Active","uen_registered_date": "2018-01-15","address": "10 Anson Road, International Plaza, #12-01, Singapore","postcode": "079903","entity_type": "Private Limited Company","company_url": "https://riabu.com","country": "Singapore","logo": "https://riabu.com/logo.png","standard_credit_terms": 30,"procurement_policies": "Standard terms apply.","comment": "Long-term partner","active": 1,"created_at": "2018-01-15T09:00:00Z","updated_at": "2024-07-01T11:00:00Z"}}}}');
            }
            else if (req.getEndpoint().contains('/order/get-list/')) {
                res.setBody('{"success": true, "data": {"items": [{"id": 101, "master_file_id": 501, "purchase_number": "PO-12345", "created_at": "2025-08-01T08:15:12.000000Z", "end_date": 1754038800, "order_items": [{"id": 301, "order_id": 101, "name": "Submit Financials", "detail": "Submit balance sheet and P&L", "deadline": "2025-08-15T00:00:00.000Z", "deadline_object": {"day": "15", "month": "08", "year": "2025"}}]}]}}');
            } else if (req.getEndpoint().contains('/service-call/')) {
                res.setBody('{"success": true, "data": {"calls": {"items": [{"id": 201, "person": "John Doe", "assigned_discrepancy_manager": "Jane Smith", "assigned_discrepancy_supervisor": "Robert Brown", "assigned_gm_ceo": "Alice White", "invoice_number": "INV-98765", "invoice_amount": "15000.00"}]}}}');
            }      
        res.setStatus('OK');
        res.setStatusCode(200);
        return res;
    }
}