public class AccountRiabuDataWrapper {
    public Boolean success;
    public Data data;
    
    public class Data {
        public Model model;
        public String company_name;
        public String claim_name;
    }
    
    public class Model {
        public Integer id;
        public Integer user_id;
        public String company_id;
        public String customer_since;
        public Integer agreed_credit_terms_day;
        public String procurement_portal;
        public String accounts_payable_contact_name;
        public String accounts_payable_email_address;
        public String accounts_payable_phone_number;
        public String accounts_payable_phone_code;
        public String email_to_send_e_invoices_to;
        public Integer special_instructions;
        public String instructions;
        public String other_emails;
        public String file;
        public String created_at;
        public String updated_at;
        public String colleagues_email;
        public String file_old_name;
        public String credit_policy_as_at;
        public Integer hidden;
        public Integer claim_id;
        public Boolean high_risk_customer;
        public Integer has_customer_signed;
        public String reason_has_not_signed;
        public Company company;
    }
    
    public class Company {
        public Integer company_id;
        public String id;
        public String name;
        public String uen;
        public String uen_status;
        public String uen_registered_date;
        public String address;
        public String postcode;
        public String entity_type;
        public String company_url;
        public String country;
        public String logo;
        public Integer standard_credit_terms;
        public String procurement_policies;
        public String comment;
        public Integer active;
        public String created_at;
        public String updated_at;
    }
    
}