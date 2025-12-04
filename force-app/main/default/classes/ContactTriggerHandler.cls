public class ContactTriggerHandler {
    public static Boolean isBatchCall = false;
    public static void createPrimaryContact( List<Contact> contactNewList ){
        Set<Id>primaryContactSet = new Set<Id>();
    	Set<Id>primaryContactAccountSet = new Set<Id>();
        for( Contact con : contactNewList ){
            if( con.isPrimary__c == true ){
                primaryContactSet.add( con.Id );
                primaryContactAccountSet.add( con.AccountId );
                if( isBatchCall == false ){
					CustomerCreationService.updateCustomer( con.Id ); 
                }
                  
            }
        }
        List<Contact>conList = [ SELECT Id,isPrimary__c FROM Contact WHERE isPrimary__c = True AND Id Not In : primaryContactSet And AccountID In : primaryContactAccountSet ];
        if( !conList.isEmpty() ){
            for( Contact con : conList ){
            	con.isPrimary__c = false;
        	}
            UPDATE conList;
        }
    }
    public static void updatePrimaryCOntact( List<Contact> contactNewList ){
        Set<Id>primaryContactSet = new Set<Id>();
    	Set<Id>primaryContactAccountSet = new Set<Id>();
        for( Contact con : contactNewList ){
            if( con.isPrimary__c == true ){
                primaryContactSet.add( con.Id );
                primaryContactAccountSet.add( con.AccountId );
                if( isBatchCall == false ){
					CustomerCreationService.updateCustomer( con.Id );
                }
                   
            }
        }
        List<Contact>conList = [ SELECT Id,isPrimary__c FROM Contact WHERE isPrimary__c = True AND Id Not In : primaryContactSet And AccountID In : primaryContactAccountSet ];
        if( !conList.isEmpty() ){
            for( Contact con : conList ){
            	con.isPrimary__c = false;
        	}
            UPDATE conList;
        }
    }
    
}