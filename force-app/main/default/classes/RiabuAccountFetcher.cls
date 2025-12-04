public with sharing class RiabuAccountFetcher  {
 
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> fetchAccountsFromRiabu() {
         Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE Expire_Date__c > TODAY 
         	LIMIT 1
        ];
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://admin.riabu.com/api/v1/master-file/list');
        req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer '+riabuObj.AccessToken__c); 
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> dataList = (List<Object>) root.get('data');
            List<Map<String, Object>> parsedList = new List<Map<String, Object>>();
            for (Object item : dataList) {
                parsedList.add((Map<String, Object>) item);
            }
            return parsedList;
        } else {
            throw new AuraHandledException(' API call failed. Code: ' + res.getStatusCode());
        }
    }
}