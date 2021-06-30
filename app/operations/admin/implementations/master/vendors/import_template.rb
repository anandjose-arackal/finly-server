class Admin::Implementations::Master::Vendors::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  attr_accessor :form, :form_import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import_template'
  # headers ({
  #     :id => "ID",
  #     :business_name => "Legal Name",
  #     :vendor_type => "Vendor Type",
  #     :vendor_id => "Vendor Code",
  #     :trade_name => "Trade Name",
  #     :mobile_number => "Mobile Number",
  #     :email => "Email",
  #     :pan => "PAN",
  #     :description => "Description",
  #     :address => "Address",
  #     :payment_term => "Payment Term Name",
  #     :gstin => "GSTIN",
  #     :gst_location => "GST Location",
  #     :state => "GST State",
  #     :vendor_bank_account_name => "Bank Account Name",
  #     :account_number => "Account Number",
  #     :ifsc => "IFSC",
  #     :destroy => "Destroy"
  # })

  def init
    super

    self.form = Form.where(company_id: self.company.id, klass_name: "Masters::Vendors::Form").first
    self.form_import = Forms::Import::Processor.(self.form, company.admins.first)
  end

  def headers
    form_import.headers
  end

  def contents
    form_import.lookup_content
  end

  def export(headers, content)
    form_import.build_import_template.url
  end

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
