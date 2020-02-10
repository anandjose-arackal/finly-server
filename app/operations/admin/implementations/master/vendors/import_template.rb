class Admin::Implementations::Master::Vendors::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import_template'
  headers ({
      :id => "ID",
      :business_name => "Legal Name",
      :vendor_type => "Vendor Type",
      :vendor_id => "Vendor Code",
      :trade_name => "Trade Name",
      :mobile_number => "Mobile Number",
      :email => "Email",
      :pan => "PAN",
      :description => "Description",
      :address => "Address",
      :gstin => "GSTIN",
      :gst_location => "GST Location",
      :state => "GST State",
      :vendor_bank_account_name => "Bank Account Name",
      :account_number => "Account Number",
      :ifsc => "IFSC",
      :destroy => "Destroy"
  })
  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
