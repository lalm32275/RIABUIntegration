public class AccountTriggerHandler {
    public static Boolean isBatchCall = false;
    public Static Void CreateAccount( List<Account> accNewList ){
        For (Account acc : accNewList) {
           if( isBatchCall == false ){
               System.enqueueJob(new RiabuAccountCreationQueue(acc.Id));
            }
  			    
    	}
    }
}