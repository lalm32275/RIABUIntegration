public class RiabuAccountVFController {

    public RiabuAccountVFController(ApexPages.StandardSetController controller) {

    }

    public String message { get; set; }

    public RiabuAccountVFController() {
        message = 'Wait, we are checking the server...';
    }
	
    public void insertAccounts() {
        try {
            List<Map<String, Object>> dataList = RiabuAccountFetcher.fetchAccountsFromRiabu();
            List<Account> accountsToInsert = new List<Account>();

            Set<String> incomingCompanyIds = new Set<String>();
            for (Map<String, Object> item : dataList) {
                if (item.containsKey('company_id')) {
                    incomingCompanyIds.add(String.valueOf(item.get('company_id')));
                }
            }

            Map<String, Account> existingAccountsMap = new Map<String, Account>();
            if (!incomingCompanyIds.isEmpty()) {
                for (Account acc : [
                    SELECT Id, RiabuCompany_Id__c 
                    FROM Account 
                    WHERE RiabuCompany_Id__c IN :incomingCompanyIds
                ]) {
                    existingAccountsMap.put(acc.RiabuCompany_Id__c, acc);
                }
            }
            for (Map<String, Object> item : dataList) {
                String companyId = item.containsKey('company_id') ? String.valueOf(item.get('company_id')) : null;
				String riabuAccId = item.containsKey('id') ? String.valueOf(item.get('id')) : null;
                if (companyId != null && riabuAccId != Null && !existingAccountsMap.containsKey(companyId)) {
                    Account acc = new Account();
                    acc.Name = item.containsKey('name') ? String.valueOf(item.get('name')) : 'Unknown Name';
                    acc.RiabuCompany_Id__c = companyId;
                    acc.RiabuAccountId__c = riabuAccId;
                    acc.Description = 'Imported from Riabu';
                    acc.Days_to_Pay__c = item.containsKey('agreed_credit_terms_day') 
                        ? String.valueOf(item.get('agreed_credit_terms_day')) : null;
                    accountsToInsert.add(acc);
                }
            }

            if (!accountsToInsert.isEmpty()) {
                AccountTriggerHandler.isBatchCall = true;
                insert accountsToInsert;
                message = accountsToInsert.size() + ' Account(s) inserted successfully!';
            } else {
                message = 'No new records to insert.';
            }
        } catch (Exception e) {
            message = 'Error during insert: ' + e.getMessage();
        }
    }
    
    public void insertOthers() {
                    Database.executeBatch( new RiabuAccountDataFetcherClass(), 1);
       
    }
    public void insertOrdersAndChatters() {
                    Database.executeBatch( new RiabuGetOrderAndChatterBatch(), 1);
       
    }
}