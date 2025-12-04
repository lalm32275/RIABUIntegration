public with sharing class RiabuCustomerService {
    private List<Account> selectedAccounts;

    public RiabuCustomerService(ApexPages.StandardSetController stdController) {
        this.selectedAccounts = (List<Account>) stdController.getSelected();
    }

    public class CustomerWrapper {
        public Boolean success;
        public List<Customer> data;
    }

    public class Customer {
        public Integer id;
        public String company_id;
        public String name;
        public String acronym;
        public Integer agreed_credit_terms_day;
        public Integer is_hidden;
        public Integer percentage;
    }


    public  PageReference fetchAndCreateAccounts() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://admin.riabu.com/api/v1/master-file/list');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer YOUR_AUTH_TOKEN'); // Replace with actual token
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                CustomerWrapper parsedResponse = (CustomerWrapper) JSON.deserialize(response.getBody(), CustomerWrapper.class);

                List<Account> accountsToInsert = new List<Account>();

                for (Customer cust : parsedResponse.data) {
                    Account acc = new Account();
                    acc.Name = cust.name;
                    acc.AccountNumber = cust.company_id;
                    acc.Description = 'Synced from Riabu';
                    acc.Rating = String.valueOf(cust.percentage);
                    accountsToInsert.add(acc);
                }

                if (!accountsToInsert.isEmpty()) {
                    insert accountsToInsert;
                    ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    '✔ Successfully synced ' + accountsToInsert.size() + ' accounts from Riabu.'
                ));
                }

               // return 'Successfully synced ' + accountsToInsert.size() + ' accounts.';
            } else {
               // return 'Failed: Status code ' + response.getStatusCode();
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Unexpected error: ' + e.getMessage()
        ));
        }
		return null;
    }
}