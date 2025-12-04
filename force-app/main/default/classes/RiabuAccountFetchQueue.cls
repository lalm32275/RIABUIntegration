public class RiabuAccountFetchQueue implements Queueable, Database.AllowsCallouts {
    private String AccountId;
    public RiabuAccountFetchQueue( Id accId ){
        this.AccountId = accId;
    }
    
    public void execute( QueueableContext qc){ 
         Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
        try {
            Account existAccount = [ SELECT Id,RiabuAccountId__c,Name,Registration_Number__c,Days_to_Pay__c,Procurement_Portal__c FROM Account WHERE Id =: AccountId LIMIT 1 ];
            List<Account>updateAccountList = new list<Account>();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://admin.riabu.com/api/v1/master-file/list');
            req.setMethod('GET');
			req.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                String jsonStr = res.getBody();
                Map<String, Object> rootMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
                List<Object> dataList = (List<Object>) rootMap.get('data');
                for (Object obj : dataList) {
                    Map<String, Object> company = (Map<String, Object>) obj;
                    if( existAccount.Name == (String) company.get('name') ){
                        
                    	existAccount.RiabuAccountId__c = String.valueOf( (Integer) company.get('id') ) ;
                    	existAccount.RiabuCompany_Id__c = (String) company.get('company_id');
                    	existAccount.Days_to_Pay__c = String.valueOf( (Integer) company.get('agreed_credit_terms_day') );
                        updateAccountList.add( existAccount );
                    }
                   
                    
                }    
            }
            if( !updateAccountList.isEmpty()){
                System.debug( updateAccountList );
                UPDATE updateAccountList;
            }
            
        } catch (Exception e) {
            System.debug( 'Exception--' + e.getMessage() );
        }
        
    }
}