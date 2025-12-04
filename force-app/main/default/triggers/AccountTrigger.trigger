trigger AccountTrigger on Account (after insert) {
  	AccountTriggerHandler.CreateAccount( Trigger.New );
}