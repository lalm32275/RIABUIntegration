public class OpportunityTriggerHandler {
    public static Boolean isBatchCall = false;
    public static void createOrder( List<Opportunity> oppNewList){
        for( Opportunity opp : oppNewList ){
            if( opp.AccountId != Null ){
                if( isBatchCall == false ){
                    CustomerCreationService.createOrder( opp.AccountId, opp.Id );
                }
                
            }
            
        }
    }
    public static void createOrderInstantly(){
         if( isBatchCall == false ){
        		System.enqueueJob( new RiabuBatchLauncher() );
         }
    }
}