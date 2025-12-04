public class RiabuCalloutService {

    @future(callout=true)
    public static void createCustomerInRiabu(Id accountId) {
        // Fetch the Account Name
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];

        String companyName = acc.Name;
        String staticSinceDate = '2024-01-01';
        String staticCreditDays = '5';

        // Generate unique UEN using name + timestamp
        String cleanedName = companyName != null ? companyName.replaceAll('[^a-zA-Z0-9]', '') : 'Account';
        String timestamp = String.valueOf(Datetime.now().getTime()); // e.g. 1723458888899
        String uniqueUEN = cleanedName + '_' + timestamp;

        // Access token (replace with secure method in production)
        String accessToken = 'your_access_token_here';

        // Construct the payload
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://admin.riabu.com/api/v1/wizard/customer');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIyIiwianRpIjoiYjgwMWYzMDNhMTZiY2Q1MzEwYzkxOGU2MjY2MjgwNjdlNmZkNzIxMmEwNzAyNTMxZmIyMTg3Njk1Zjc0MTk4ZDdkMGM5YzU5Y2RkYzcxYmYiLCJpYXQiOjE3NTI0ODI0ODEsIm5iZiI6MTc1MjQ4MjQ4MSwiZXhwIjoxNzg0MDE4NDgxLCJzdWIiOiIxMDkiLCJzY29wZXMiOltdfQ.g4kVqIf2Oa62iO37o0rUXhxEJiSsLkq5dFtC_A5S8YJcWUL03S99dEuZd4BM4ZTvS4DswRbFd4wt8dks8P8XLQkTo92CuvUiQmIVGFlypUriSsiAkpCxkJA7DgZ7G-WbGMiPFPR7-PPvrO7R9BHBBDtojjm1mhQ7OLsfo0_E7Y3hjox6zOzBq5SSDlNnIjoELZZua9sIb_DKUVclURGb3qOrI9RUXsNkgfDrVsue089NFz9e6U-3DzrUqWwgrBWl-2Pul95j8_YtOAYtHQuL70reBcnsHhn8lOsdAKPkAeiKzRit_cgWMUm0-9OC4cVs2Jxl62WeSSzyYc97iRBiP9oUjZAKWlYUWTAJrvlehcPCwBFmFuiq2k5SCm01idvD57GVy3bD58i8_Kg-GtejaTmnibAb5kdjczfhySrk074XP-9BP2PfGQvwsITWt7xVxOvdz3rqUKQtdF_6qWvhKxd8GLjT_uUOwr35lly9n4uupB1mcz4h1w8prZpFTfm_0OH8h2oyTBZFNQglXccZlUE9dKIxEiYBIEYHJm-31HFh5Tbv17jLlg6HyFEFuI3W2T9lbmlAXv5XeYAzM86L78yMYHyNCYbltkQYkM6EwAYUM6kS6vJWbLImau_K3ZJ5m0Uca59iJ6JuUZ-Tq8ATUole8FOU7t0vOAY-xLq2vw4');

        String body = 
            'company_name=' + EncodingUtil.urlEncode(companyName, 'UTF-8') +
            '&company_uen=' + EncodingUtil.urlEncode(uniqueUEN, 'UTF-8') +
            '&customer_since=' + EncodingUtil.urlEncode(staticSinceDate, 'UTF-8') +
            '&agreed_credit_terms_day=' + EncodingUtil.urlEncode(staticCreditDays, 'UTF-8');

        req.setBody(body);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('✅ RIABU API Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('❌ Error during RIABU callout: ' + e.getMessage());
        }
    }
}