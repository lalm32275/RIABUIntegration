/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RiabuAuthTokenUtil {
    @AuraEnabled
    public static void getAccessToken() {
        Riabu__c riabuObj = [
            SELECT Id, Name, Client_Id__c, client_secret__c, Password__c, refreshToken__c, AccessToken__c, Expire_Date__c 
            FROM Riabu__c 
            WHERE client_secret__c != Null AND Client_Id__c != Null AND Password__c != Null 
            LIMIT 1
        ];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://admin.riabu.com/api/v1/oauth/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');  
        Map<String, String> payload = new Map<String, String>{
            'username' => riabuObj.Name,
            'password' => riabuObj.Password__c,
            'grant_type' => 'password',
            'client_id' => riabuObj.Client_Id__c,
            'client_secret' => riabuObj.client_secret__c
        };
        
        req.setBody(JSON.serialize(payload));  
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            String jsonResponse = res.getBody();
            System.debug('jsonResponse: ' + jsonResponse);
            
            Map<String, Object> tokenMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            
            riabuObj.AccessToken__c = (String) tokenMap.get('access_token');
            riabuObj.refreshToken__c = (String) tokenMap.get('refresh_token');
            
            Integer expiresIn = (Integer) tokenMap.get('expires_in');
            riabuObj.Expire_Date__c = System.now().addSeconds(expiresIn);
        } else {
            System.debug('Failed to get token: ' + res.getBody());
        }
        
        if (riabuObj.Expire_Date__c != null && riabuObj.AccessToken__c != null && riabuObj.refreshToken__c != null) {
            update riabuObj;
        }
    }
}