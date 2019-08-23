class Admin::Implementations::Master::Vendors::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import_template'
  headers ({
      :id => "ID",
      :name => "Vendor NAme",
      :vendor_type => "Vendor Type",
      :vendor_id => "Vendor Code",
      :business_name => "Business Name",
      :mobile_number => "Mobile Number",
      :email => "Email",
      :pan => "PAN",
      :state => "State",
      :description => "Description",
      :address => "Address",
      :gstin => "GSTIN",
      :gst_location => "GST Location",
      :vendor_bank_account_name => "Bank Account Name",
      :account_number => "IFSC",
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
