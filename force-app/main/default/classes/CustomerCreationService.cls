public class CustomerCreationService {
    public static void createCustomer(Id AccountId) {
        
         Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
 		Account acc = [SELECT Id, Name,Registration_Number__c,CreatedDate,Days_to_Pay__c,Procurement_Portal__c FROM Account WHERE Id = :accountId LIMIT 1];
        String endpoint = 'https://admin.riabu.com/api/v1/wizard/customer';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 

        // Different edge case test data
        String body = 
            'company_name=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8') +
            '&company_uen=' + EncodingUtil.urlEncode(acc.Registration_Number__c, 'UTF-8') +
            '&customer_since=' + EncodingUtil.urlEncode(acc.CreatedDate.format('yyyy-MM-dd'), 'UTF-8') +
            '&agreed_credit_terms_day=' + EncodingUtil.urlEncode(acc.Days_to_Pay__c, 'UTF-8')+
            '&procurement_portal=' + EncodingUtil.urlEncode(acc.Procurement_Portal__c, 'UTF-8'); 
            /*'&accounts_payable_contact_name=' + EncodingUtil.urlEncode('Mr. Edge Case', 'UTF-8') +
            '&accounts_payable_email_address=' + EncodingUtil.urlEncode('edge.test+payable@domain-test.org', 'UTF-8') +
            '&accounts_payable_phone_number=' + EncodingUtil.urlEncode('+65-9999-8888', 'UTF-8') +
            '&email_to_send_e_invoices_to=' + EncodingUtil.urlEncode('invoices+edge@domain-test.org', 'UTF-8') +
            '&high_risk_customer=' + EncodingUtil.urlEncode('1', 'UTF-8') +
            '&has_customer_signed=' + EncodingUtil.urlEncode('0', 'UTF-8') +
            '&reason_has_not_signed=' + EncodingUtil.urlEncode('Legal team still reviewing T&Cs', 'UTF-8');*/

        req.setBody(body);

        // Send the HTTP request
        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug('Status: ' + res.getStatus());
            System.debug('Status code: ' + res.getStatusCode());
            System.debug('Response body: ' + res.getBody());

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug(' Customer created successfully.');
            } else {
                System.debug(' Failed to create customer. Check response for details.');
            }
        } catch (Exception ex) {
            System.debug(' Exception occurred: ' + ex.getMessage());
        }
    }
    @future(callout=true)
    public static void updateCustomer( Id contactId ) {
        Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
 		Contact con = [SELECT Id,LastName, Account.RiabuAccountId__c,Email,Phone,AccountId,E_Invoice_Email__c,high_risk_customer__c,has_customer_signed__c,reason_has_not_signed__c FROM Contact WHERE Id = :contactId LIMIT 1];
        String endpoint = 'https://admin.riabu.com/api/v1/master-file/update/'+con.Account.RiabuAccountId__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
	   	req.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 

        String body =
            'accounts_payable_contact_name=' + EncodingUtil.urlEncode( con.LastName != Null ? con.LastName : '', 'UTF-8') +
            '&accounts_payable_email_address=' + EncodingUtil.urlEncode( con.E_Invoice_Email__c != Null ? con.E_Invoice_Email__c : '', 'UTF-8') +
            '&accounts_payable_phone_number=' + EncodingUtil.urlEncode( con.Phone != Null ? con.Phone : '', 'UTF-8') +
            '&email_to_send_e_invoices_to=' + EncodingUtil.urlEncode( con.Email != Null ? con.Email : ''  , 'UTF-8') +
            '&high_risk_customer=' + EncodingUtil.urlEncode( String.valueOf( con.high_risk_customer__c == true ? 1 : 0 ), 'UTF-8') +
            '&has_customer_signed=' + EncodingUtil.urlEncode( String.valueOf( con.has_customer_signed__c == true ? 1 : 0), 'UTF-8') +
            '&reason_has_not_signed=' + EncodingUtil.urlEncode( con.reason_has_not_signed__c != Null ? con.reason_has_not_signed__c : '', 'UTF-8');

        req.setBody(body);
        System.debug( 'req Body' + body );
        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug('Status: ' + res.getStatus());
            System.debug('Status code: ' + res.getStatusCode());
            System.debug('Response body: ' + res.getBody());

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug(' Customer created successfully.');
            } else {
                System.debug(' Failed to create customer. Check response for details.');
            }
        } catch (Exception ex) {
            System.debug(' Exception occurred: ' + ex.getMessage());
        }
    }
    
    @future(callout=true)
    public static void createOrder( String riabuAccountId, String newlyCreatedOppId ) {
        Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
        Account acc = [SELECT Id, RiabuAccountId__c,Name,Registration_Number__c,CreatedDate,Days_to_Pay__c,Procurement_Portal__c FROM Account WHERE Id = :riabuAccountId LIMIT 1];
        Opportunity oppRecord = [SELECT Id,riabu_Order_Id__c FROM Opportunity Where Id = : newlyCreatedOppId LIMIT 1];
		String endpoint = 'https://admin.riabu.com/api/v1/order/create-main';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 
        String body = 'master_file_id=' + EncodingUtil.urlEncode( acc.RiabuAccountId__c, 'UTF-8');
        req.setBody(body);
        Http http = new Http();
        try {
            HTTPResponse res = http.send(req);
            System.debug('Status: ' + res.getStatus());
            System.debug('Status code: ' + res.getStatusCode());
            System.debug('Response body: ' + res.getBody());

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug(' Order created successfully.');
                Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped( res.getBody());
                Map<String, Object> OrderMap = (MAp<String,Object>) dataMap.get( 'data' );
                oppRecord.riabu_Order_Id__c = String.valueOf( OrderMap.get('order_id') );
                
            } else {
                System.debug(' Failed to create Order. Check response for details.');
            }
            if( oppRecord.riabu_Order_Id__c != Null ){
                UPDATE oppRecord;
            }
        } catch (Exception ex) {
            System.debug(' Exception occurred: ' + ex.getMessage());
        }
     

    }
}