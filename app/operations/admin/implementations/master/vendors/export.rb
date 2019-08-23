class Admin::Implementations::Master::Vendors::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.export'

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
    company.yes_bank_vendors
  end

  def id(vendor)
    vendor.id
  end

  def name(vendor)
    vendor.name
  end

  def vendor_type(vendor)
    vendor.vendor_type&.name
  end

  def vendor_id(vendor)
    vendor.vendor_id
  end

  def business_name(vendor)
    vendor.business_name
  end

  def mobile_number(vendor)
    vendor&.gstin_locations&.first&.poc_mobile_number
  end

  def email(vendor)
    vendor&.gstin_locations&.first&.poc_email
  end

  def pan(vendor)
    vendor.pan
  end

  def state(vendor)
    vendor.gstin_locations.first&.state&.name rescue ''
  end

  def description(vendor)
    vendor.description
  end

  def address(vendor)
    vendor.gstin_locations&.first&.address rescue ''
  end

  def gstin(vendor)
    vendor.gstin_locations&.first&.gstin rescue ''
  end

  def gst_location(vendor)
   vendor.gstin_locations&.first&.location rescue ''
  end

  def account_number(vendor)
   vendor.bank_accounts&.first&.account_number rescue ''
  end

  def ifsc(vendor)
    vendor.bank_accounts&.first&.ifsc rescue ''
  end

  def vendor_bank_account_name(vendor)
    vendor.bank_accounts&.first&.name rescue ''
  end

  def destroy(vendor)
    ''
  end

  def post_process
  end

end
