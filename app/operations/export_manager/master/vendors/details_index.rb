class ExportManager::Master::Vendors::DetailsIndex < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Vendor Export'
  configurable true
  system :vp
  # screen 'vendors.index'
  # handle :vendor_details
  validate :input

  attribute :vendor_business_name
  attribute :vendor_id
  attribute :authorized
  attribute :name
  attribute :mobile_number
  attribute :email
  attribute :created_by
  attribute :pan
  attribute :address
  attribute :gstin
  attribute :state_code
  attribute :description
  attribute :vendor_type
  attribute :default_account_number
  attribute :default_account_ifsc
  attribute :created_at

  def input
    params[:beneficiary_type] = 2
    op = BankTransfer::AccountOwners::Index.(user, params)
    op.account_owners
  end

  def vendor_business_name(vendor)
    vendor.business_name
  end

  def vendor_id(vendor)
    vendor.vendor_id
  end

  def authorized(vendor)
    vendor.authorized
  end

  def name(vendor)
    vendor.name
  end

  def mobile_number(vendor)
    vendor.name
  end

  def email(vendor)
    vendor.email
  end

  def created_by(vendor)
    vendor.created_by&.name
  end

  def pan(vendor)
    vendor.pan
  end

  def gstin(vendor)
    vendor.gst
  end

  def state_code(vendor)
    vendor.state_code&.full_name
  end

  def description(vendor)
    vendor.description
  end

  def vendor_type(vendor)
    vendor.vendor_type&.name
  end

  def created_at(vendor)
    vendor.created_at&.strftime("%d-%b-%Y")
  end

  def address(vendor)
    vendor.address
  end

  def default_account_number(vendor)
    account = vendor.bank_accounts.default_accounts.first
    account = vendor.bank_accounts.first if account.blank?
    account&.account_number
  end

  def default_account_ifsc(vendor)
    account = vendor.bank_accounts.default_accounts.first
    account = vendor.bank_accounts.first if account.blank?
    account&.ifsc
  end

end