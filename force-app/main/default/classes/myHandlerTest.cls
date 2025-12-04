@isTest
private class myHandlerTest {
@istest
     static void handleInboundEmail(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = '*Company Name:*uyfytdydytest\n*Name:*mr test\n*Email:*test@test.com\n*Position/Title:*test\n*Contact Number:*0123456789\n*Training  Type:*tes\n*Desired Training Date:*02/05/2024';
        myHandler emailProcess = new myHandler();
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail1a(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'First Name:uyfytdydytest\nLast Name:test\nEmail:test@test.com\nCompany:test\nPhone:0123456789\nDropdown Field:tes\nJoin our exclusive mail list:Checked';
        myHandler emailProcess = new myHandler();
        emailProcess.handleInboundEmail(email, env);
    }

    @istest
     static void handleInboundEmail2(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = '*Company Name:*uyfytdydytest\n*Name:*mr test test\n*Email:*test@test.com\n*Position/Title:*test\n*Contact Number:*0123456789\n*Training  Type:*tes\n*Desired Training Date:*02/05/2024';
        myHandler emailProcess = new myHandler();
        emailProcess.handleInboundEmail(email, env);
    }

@istest
     static void handleInboundEmail3(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = '*Company Name:*Adlina Zulaimy\n*Name:*mr test test\n*Email:*test@test.com\n*Position/Title:*test\n*Contact Number:*0123456789\n*Training  Type:*tes\n*Desired Training Date:*02/05/2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail4(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = '*Company Name:*Adlina Zulaimy\n*Name:*mr test test\n*Email:*test@test.com\n*Position/Title:*test\n*Contact Number:*0123456789\n*Training  Type:*tes\n*Desired Training Date:*02/05/2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail5(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes\n*Desired Training Date:*02/05/2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail6(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes\nDesired Training Date: Monday, May 13, 2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail7(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes\nDesired Training Date: Monday, December 13, 2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail8(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes\nDesired Training Date: Monday, December 13, 2024';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail9(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname='test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }
@istest
     static void handleInboundEmail10(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Company Name: Adlina Zulaimy\nName: mr test test\n*Email:*test@test.com\nPosition/Title: test\nContact Number: 0123456789\nTraining Type: tes';
        myHandler emailProcess = new myHandler();
         Account acc = new account(name='Adlina Zulaimy');
         insert acc;
         contact con = new contact(accountid=acc.id,Salutation='mr',firstname='test',lastname=' test',email='test@test.com',title='test',MobilePhone='0123456789');
         insert con;
        emailProcess.handleInboundEmail(email, env);
    }

}