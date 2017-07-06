# operation that hits the ItzCash API to generate a customer ID for a particular company
class ItzCash::Kyc::CreateCustomerId < ItzCash::Base

  attr_accessor :company, :poc, :company_kyc

  def env_key
    'generate_customer_id'
  end

  def init
    super()
    self.company = params[:company]
    self.company_kyc = company.company_kyc
    self.poc = company.users.point_of_contact.first
  end

  def post_params
    {
        customer: {
            custtypename: "FINLY",
            dobestablishment: format_date_of_establishment,
            name1: company.name,
            street2: company_kyc.street_2,
            mobileno: poc.mobile_number,
            emailid: poc.email,
            fnmcontactperson: poc.first_name,
            lnmcontactperson: poc.last_name,
            firmtypename: "E01",
            remark: "Customer Request",
            pincode: company_kyc.pin_code,
            street3: company_kyc.street_3,
            citycode: "1977"
        }
    }
  end

  private

  def format_date_of_establishment
    date = company.company_kyc.date_of_establishment
    out = "#{date.strftime("%d")}.#{date.strftime("%m")}.#{date.strftime("%Y")}"
  end
end