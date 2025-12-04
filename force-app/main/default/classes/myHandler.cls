public with sharing class myHandler implements Messaging.InboundEmailHandler {
 
  public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                         Messaging.InboundEnvelope env) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
	Boolean multipleCostCentres;  
    System.debug('email'+email);
    System.debug('env'+env);
    List<Messaging.InboundEmail.BinaryAttachment> attachments = email.binaryAttachments;
    String myPlainText = '';
    myPlainText = email.plainTextBody;
    List<String> plainTextLines = new List<String>();
    Map<string,string> record  = new map<string,string>();
    if (myPlainText != null) {
        plainTextLines = myPlainText.split('\n');
    }
    for (String line : plainTextLines) {
        List<string> stringdata3  = line.split(':');
            if(stringdata3.size()>1){
                record.put(stringdata3[0],stringdata3[1]);
            }
    }
	System.debug('Record '+record);
    if(record.containskey('Join our exclusive mail list ') || record.containskey('Join our exclusive mail list') ||  record.containskey('*Join our exclusive mail list')){
        System.debug(record.get('First Name'));
        System.debug(record.get('Last Name'));
        System.debug(record.get('Company'));
        System.debug(record.get('Phone'));
        System.debug(record.get('Email'));
        System.debug(record.get('Dropdown Field'));
        System.debug(record.get('Join our exclusive mail list'));
        string firstname = '';
        string lastname = 'Hong Bao Media';
        string oppname = 'Hong Bao Media';
        string emailfield = '';
        string phonenumber = '';
        String company = '';
        if(record.get('First Name') != null && record.get('First Name').split(':').size()>0){
                if(record.get('First Name').split(':')[0] != null){
                    firstname = (record.get('First Name').split(':')[0]).trim();
                }
        }
        if(record.get('Last Name') != null && record.get('Last Name').split(':').size()>0){
                if(record.get('Last Name').split(':')[0] != null){
                    lastname = (record.get('Last Name').split(':')[0]).trim(); 
                }
        }
        if(record.get('Company') != null && record.get('Company').split(':').size()>0){
                if(record.get('Company').split(':')[0] != null){
                    company = (record.get('Company').split(':')[0]).trim();
                }
        }
        if(record.get('Phone') != null && record.get('Phone').split(':').size()>0){
                if(record.get('Phone').split(':')[0] != null){
                    phonenumber = (record.get('Phone').split(':')[0]).trim();
                }
        }
        if(record.get('Email') != null && record.get('Email').split(':').size()>0){
                if(record.get('Email').split(':')[0] != null){
                    emailfield = (record.get('Email').split(':')[0]).trim();
                }
        }
        if(record.get('Dropdown Field') != null && record.get('Dropdown Field').split(':').size()>0){
                if(record.get('Dropdown Field').split(':')[0] != null){
                    oppname = (record.get('Dropdown Field').split(':')[0]).trim();
                }
        } 
        List<account> acc;
        id accountid;
        if(company != ''){
         	acc = [select id from account where Name =:company limit 1]; 
            if(acc.size()>0){
                accountid = acc[0].Id;
            }else{
                account accd = new account(name=company,ownerId='00584000000hVsRAAU');
                insert accd;
                accountid = accd.Id;
            }
        }else{
                account accdc = new account(name='Hong Bio Media',ownerId='00584000000hVsRAAU');
                insert accdc;
                accountid = accdc.Id;
        }
        List<contact> conlist =  [select id,accountid,firstname,MobilePhone,Title,Email from contact where accountid=:accountid AND (MobilePhone =:phonenumber OR Email =:emailfield) limit 1];
        id contactid;
        if(conlist.size()>0){
            contactid = conlist[0].id;
        }else{
            contact con = new contact(Salutation = 'Mr.',FirstName = firstname,LastName  = lastname,Email=emailfield,Title =company,MobilePhone = phonenumber,accountid=accountid);
            insert con; 
            contactid = con.id;  
        }
        opportunity opp = new opportunity(name=oppname,closedate=date.today(),stagename='Enquiry received – MUST REPLY!',Contact__c=contactid);
        insert opp;
        
                      if(email.binaryAttachments != null){
                        for(Messaging.InboundEmail.BinaryAttachment attachment : attachments) {
                            String attachmentName = attachment.fileName;
                            Blob attachmentBody = attachment.body;
                            System.debug('attachment'+attachmentBody);
                             insertAttachmentIntoSalesforce(attachmentName, attachmentBody,opp.Id);
                        }   
                      }
        lead led = new lead(Salutation = 'Mr.',FirstName=firstname,LastName = lastname,Email=emailfield,Title =company,MobilePhone = phonenumber,Company=company,FromEmail__c=true);
        insert led;
        return result;
    }else{
            String accountname = 'Hong Bao Media';
            if(record.get('*Company Name') != null && record.get('*Company Name').split('\\*').size()>1){
                if(record.get('*Company Name').split('\\*')[1] != null){
                    accountname = record.get('*Company Name').split('\\*')[1];   
                }
            }else if(record.get('Company Name') != null && record.get('Company Name').split(':').size()>0){
                System.debug('24'+record.get('Company Name').split(':')[0]);
                if(record.get('Company Name').split(':')[0] != null){
                System.debug('24'+record.get('Company Name').split(':')[0]);
                    accountname = (record.get('Company Name').split(':')[0]).trim();   
                } 
            }
            String oppname = '';
            List<account> acclist = [select id from account where name =:accountname limit 1];
            Account acc;
            if(acclist.size()<=0){                                                   
                acc = new account(Name = accountname,ownerId='00584000000hVsRAAU'); 
                insert acc; 
            } 
              System.debug('31'+record.get('*Name')); 
             string contactname = 'Mrs Adlina Zulaimy';
             if(record.get('*Name') != null && record.get('*Name').split('\\*').size()>1){
                 if(record.get('*Name').split('\\*')[1] != null){
                    contactname = record.get('*Name').split('\\*')[1];
                 }
             }else if(record.get('Name') != null && record.get('Name').split(':').size()>0){
                 if(record.get('Name').split(':')[0] != null){
                    contactname = (record.get('Name').split(':')[0]).trim();
                 }
             }
            List<string>contactnameaftersplit =  contactname.split(' ');
            String contactemail = '';
            if(record.get('*Email') != null && record.get('*Email').split('\\*').size()>1){
                if(record.get('*Email').split('\\*')[1] != null){
                    contactemail = record.get('*Email').split('\\*')[1];
                }                                   
            }
            String contacttitle = '';
            if(record.get('*Position/Title') != null && record.get('*Position/Title').split('\\*').size()>1){
                if(record.get('*Position/Title').split('\\*')[1] != null){
                        contacttitle = record.get('*Position/Title').split('\\*')[1];  
                }                                                
            }else if(record.get('Position/Title') != null && record.get('Position/Title').split(':').size()>0){
                if(record.get('Position/Title').split(':')[0] != null){
                        contacttitle = (record.get('Position/Title').split(':')[0]).trim();  
                }    
            }
            String contactnumber = '';
            if(record.get('*Contact Number') != null && record.get('*Contact Number').split('\\*').size()>1){
                if(record.get('*Contact Number').split('\\*')[1] != null){
                    contactnumber = record.get('*Contact Number').split('\\*')[1];  
                }
            }else if(record.get('Contact Number') != null && record.get('Contact Number').split(':').size()>0){
                if(record.get('Contact Number').split(':')[0] != null){
                    contactnumber = (record.get('Contact Number').split(':')[0]).trim();  
                }
            }    
             
                    contact con;
                    List<contact> conlist = new list<contact>();
            if(acclist.size()>0){
                System.debug('87'+contactnameaftersplit+''+contacttitle+contactnumber+contactemail);
                  conlist = [select id,accountid,firstname,MobilePhone,Title,Email from contact where accountid=:acclist[0].id AND (MobilePhone =:contactnumber OR Email =:contactemail) limit 1]; 
                if(conlist.size()<=0){
                     if(contactnameaftersplit.size()>2){ 
                    con = new contact(Salutation = contactnameaftersplit[0],FirstName = contactnameaftersplit[1],LastName  = contactnameaftersplit[2],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,AccountId = acclist[0].Id); 
                    insert con;
                }
                else{
                    con = new contact(Salutation = contactnameaftersplit[0],FirstName = '',LastName  = contactnameaftersplit[1],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,AccountId = acclist[0].Id); 
                    insert con;
                }
                }
            }else{
                  if(contactnameaftersplit.size()>2){ 
                    con = new contact(Salutation = contactnameaftersplit[0],FirstName = contactnameaftersplit[1],LastName  = contactnameaftersplit[2],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,AccountId = acc.Id); 
                    insert con;
                }else{
                    con = new contact(Salutation = contactnameaftersplit[0],FirstName = '',LastName  = contactnameaftersplit[1],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,AccountId = acc.Id); 
                    insert con;
                }        
            }
                                                                
            //String opportunityname = oppname+date.today();
            String opportunityname = 'Hong Bao Media';
            if(record.get('*Training  Type') != null && record.get('*Training  Type').split('\\*').size()>1){
                if(record.get('*Training  Type').split('\\*')[1] != null){
                    opportunityname = record.get('*Training  Type').split('\\*')[1];               
                }                                          
            }else if(record.get('Training Type') != null && record.get('Training Type').split(':').size()>0){
            System.debug('143'+record.get('Training Type').split(':')[0]);
                if(record.get('Training Type').split(':')[0] != null){
            System.debug('143'+record.get('Training Type').split(':')[0]);
                    opportunityname = (record.get('Training Type').split(':')[0]).trim();               
                }  
            }
            
            String dateString = '';
            Date opportunitydate;
            if(record.get('*Desired Training Date') != null && record.get('*Desired Training Date').split('\\*').size()>1)
            {
                if(record.get('*Desired Training Date').split('\\*')[1] != null){
                        dateString = record.get('*Desired Training Date').split('\\*')[1];
                    	List<String> dateParts2 = dateString.split(', ');
                    if(dateParts2.size() >1){
                        String monthDay = dateParts2[1]; 
                        List<String> monthDayParts = monthDay.split(' ');
                        String month = monthDayParts[0]; 
                        Integer day = Integer.valueOf(monthDayParts[1]); 
                        Integer year = Integer.valueOf(dateParts2[2]); 
                        Integer monthInt;
                        switch on month {
                            when 'January' { monthInt = 1; }
                            when 'February' { monthInt = 2; }
                            when 'March' { monthInt = 3; }
                            when 'April' { monthInt = 4; }
                            when 'May' { monthInt = 5; }
                            when 'June' { monthInt = 6; }
                            when 'July' { monthInt = 7; }
                            when 'August' { monthInt = 8; }
                            when 'September' { monthInt = 9; }
                            when 'October' { monthInt = 10; }
                            when 'November' { monthInt = 11; }
                            when 'December' { monthInt = 12; }
                        }
                            Date parsedDate = Date.newInstance(year, monthInt, day);
                            opportunitydate = parsedDate;
                        
                        
                    }else{
                        List<String> dateParts = dateString.split('/');
                        Integer month = Integer.valueOf(dateParts[1]);
                        String myString = dateParts[0].replaceAll('\\s', '');
                        Integer day = Integer.valueOf(myString);
                        Integer year = Integer.valueOf(dateParts[2]);
                        opportunitydate = Date.newInstance(year, month, day);
                    }
                  }
            }else if(record.get('Desired Training Date') != null && record.get('Desired Training Date').split(':').size()>0){
                if(record.get('Desired Training Date').split(':')[0] != null){
                        List<String> dateParts = record.get('Desired Training Date').split(':')[0].split(', ');
                        String monthDay = dateParts[1]; 
                        List<String> monthDayParts = monthDay.split(' ');
                        String month = monthDayParts[0]; 
                        Integer day = Integer.valueOf(monthDayParts[1]); 
                        Integer year = Integer.valueOf(dateParts[2]); 
                        Integer monthInt;
                        switch on month {
                            when 'January' { monthInt = 1; }
                            when 'February' { monthInt = 2; }
                            when 'March' { monthInt = 3; }
                            when 'April' { monthInt = 4; }
                            when 'May' { monthInt = 5; }
                            when 'June' { monthInt = 6; }
                            when 'July' { monthInt = 7; }
                            when 'August' { monthInt = 8; }
                            when 'September' { monthInt = 9; }
                            when 'October' { monthInt = 10; }
                            when 'November' { monthInt = 11; }
                            when 'December' { monthInt = 12; }
                        }
                            Date parsedDate = Date.newInstance(year, monthInt, day);
                            opportunitydate = parsedDate;
                }
            }else{
               opportunitydate = date.today(); 
            }
            System.debug('69'+con);
            System.debug('69'+conlist+opportunityname);
            System.debug('69'+acclist+opportunitydate);
        	
        	string mpc = record.get('Multiple Cost Centres');
        	System.debug('mpc '+mpc+' '+record.get('Multiple Cost Centres')+' false');
        	multipleCostCentres = record.get('Multiple Cost Centres')==' true'?true:false;
        	System.debug('281 '+multipleCostCentres);
        	opportunity opp;
            if(conlist.size()<=0 && acclist.size()<=0){
                system.debug('inside 1');
             opp = new opportunity(name=opportunityname,closedate=opportunitydate,stagename='Enquiry received – MUST REPLY!',Contact__c=con.Id,accountId = acc.Id, PO_Received__c =multipleCostCentres);
             insert opp; 
                
            }else if(conlist.size()<=0 && acclist.size()>0){  
                                system.debug('inside 2');
             opp = new opportunity(name=opportunityname,closedate=opportunitydate,stagename='Enquiry received – MUST REPLY!',Contact__c=con.Id,accountId =acclist[0].Id,PO_Received__c =multipleCostCentres);
             insert opp;
            }else if(conlist.size()>0 && acclist.size()<=0){  
                                system.debug('inside 3');
             opp = new opportunity(name=opportunityname,closedate=opportunitydate,stagename='Enquiry received – MUST REPLY!',Contact__c=conlist[0].Id,accountId =acc.Id,PO_Received__c =multipleCostCentres);
             insert opp;
                
            }else{   
                                system.debug('inside 4');
             opp = new opportunity(name=opportunityname,closedate=opportunitydate,stagename='Enquiry received – MUST REPLY!',Contact__c=conlist[0].Id,accountId =acclist[0].Id,PO_Received__c =multipleCostCentres);
             insert opp;
                
            }
        
                      if(email.binaryAttachments != null){
                        for(Messaging.InboundEmail.BinaryAttachment attachment : attachments) {
                            String attachmentName = attachment.fileName;
                            Blob attachmentBody = attachment.body;
                            System.debug('attachment'+attachmentBody);
                             insertAttachmentIntoSalesforce(attachmentName, attachmentBody,opp.Id);
                        }   
                      }
             if(contactnameaftersplit.size()>2){
                lead led = new lead(Salutation = contactnameaftersplit[0],FirstName=contactnameaftersplit[1],LastName = contactnameaftersplit[2],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,Company=accountname,FromEmail__c=true);
                insert led;       
             System.debug('57'+led.FromEmail__c);                                                    
             }else{
                lead led = new lead(Salutation = contactnameaftersplit[0],lastname=contactnameaftersplit[1],Email=contactemail,Title =contacttitle,MobilePhone = contactnumber,Company=accountname,FromEmail__c=true);
                insert led;  
             System.debug('57'+led.FromEmail__c);
             }
             System.debug('57'+con);
            return result;
        
    }
  }
    public static void insertAttachmentIntoSalesforce(String attachmentName, Blob attachmentBody,String parentiddata) {
        Attachment newAttachment = new Attachment();
        newAttachment.Name = attachmentName;
        newAttachment.Body = attachmentBody;
        newAttachment.ParentId = parentiddata; // Set the parent record Id
        
        // Insert the attachment
        insert newAttachment;
    }
}