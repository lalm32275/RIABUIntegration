trigger OpportunityTrigger on Opportunity ( After Insert, After Update ) {
    if( Trigger.isAfter && Trigger.isInsert ){
        OpportunityTriggerHandler.createOrder( Trigger.New );
            
    }
    if( Trigger.isAfter && Trigger.isUpdate ){
        OpportunityTriggerHandler.createOrderInstantly();
    }
}