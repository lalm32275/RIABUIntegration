public class RiabuAccountJob  implements Queueable, Database.AllowsCallouts 
{    
        public  void execute( QueueableContext context) {
        try {
            List<Map<String, Object>> accounts = RiabuAccountFetcher.fetchAccountsFromRiabu();
            system.debug('accounts----'+accounts);
             List<Account> accountsToInsert = new List<Account>();
           

             //  Extract all company IDs from incoming data
            Set<String> incomingCompanyIds = new Set<String>();
            for (Map<String, Object> item : accounts) {
                if (item.containsKey('company_id')) {
                    incomingCompanyIds.add(String.valueOf(item.get('company_id')));
                }
            }

            //Query existing Accounts with same RiabuCompany_Id__c
            Map<String, Account> existingAccountsMap = new Map<String, Account>();
            system.debug( 'incomingCompanyIds-----'+ incomingCompanyIds );
            if (!incomingCompanyIds.isEmpty()) {
                for (Account acc : [
                    SELECT Id, RiabuCompany_Id__c 
                    FROM Account 
                    WHERE RiabuCompany_Id__c IN :incomingCompanyIds
                ]) {
                    existingAccountsMap.put(acc.RiabuCompany_Id__c, acc);
                }
            }
            system.debug( 'existingAccountsMap' + existingAccountsMap );
            //  Create Account records only if not existing
            for (Map<String, Object> item : accounts) {
                String companyId = item.containsKey('company_id') ? String.valueOf(item.get('company_id')) : null;
                String riabuAccId = item.containsKey('id') ? String.valueOf(item.get('id')) : null;
                if (companyId != null && riabuAccId != Null && !existingAccountsMap.containsKey(companyId)) {
                    Account acc = new Account();
                    acc.Name = item.containsKey('name') ? String.valueOf(item.get('name')) : 'Unknown Name';
                    acc.RiabuCompany_Id__c = companyId;
                    acc.Description = 'Imported from Riabu';
                    acc.Days_to_Pay__c = item.containsKey('agreed_credit_terms_day') 
                        ? String.valueOf(item.get('agreed_credit_terms_day')) : null;
                    acc.RiabuAccountId__c = riabuAccId;
                    accountsToInsert.add(acc);
                }
            }
            system.debug( 'accountsToInsert'+ accountsToInsert );
            //  Insert new records
            if (!accountsToInsert.isEmpty()) {
                AccountTriggerHandler.isBatchCall=true;
                system.debug(accountsToInsert);
                insert accountsToInsert;
                
            } 
           
        } catch (Exception e) {
            System.debug('Error in RiabuScheduler: ' + e.getMessage());
        }
    }
}