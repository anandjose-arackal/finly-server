class ExportManager::Master::Vendors::Index < ExportManager::Builders::Spreadsheet
  attr_accessor :vendor_ba

  label 'Export'
  description 'Vendor Export'
  configurable true
  system :vp
  screen 'vendors.index'
  resolver 'vendors.default'
  handle :vendors

  attribute :vendor_business_name
  attribute :vendor_trade_name
  attribute :vendor_id
  attribute :name
  attribute :msme_registered
  attribute :msme_registration_number
  attribute :mobile_number
  attribute :email
  attribute :created_by
  attribute :pan
  attribute :poc_name
  attribute :poc_email
  attribute :gstin_location_address
  attribute :gstin
  attribute :tds_percentage
  attribute :state_code
  attribute :description
  attribute :vendor_type
  attribute :default_account_number
  attribute :default_account_name
  attribute :default_account_ifsc
  attribute :second_account_number
  attribute :second_account_name
  attribute :second_account_ifsc
  attribute :third_account_number
  attribute :third_account_name
  attribute :third_account_ifsc
  attribute :fourth_account_number
  attribute :fourth_account_name
  attribute :fourth_account_ifsc
  attribute :created_at
  attribute :active

  def vendor_business_name(vendor)
    vendor.business_name
  end

  def vendor_trade_name(vendor)
    vendor.trade_name
  end

  def vendor_id(vendor)
    vendor.vendor_id
  end

  def name(vendor)
    vendor.name
  end

  def msme_registered(vendor)
    vendor.msme_registered.to_s
  end

  def msme_registration_number(vendor)
    vendor.msme_registration_number
  end

  def poc_name(vendor)
    vendor.gstin_locations&.first&.poc_name
  end

  def mobile_number(vendor)
    vendor.mobile_number
  end

  def email(vendor)
    vendor.email
  end

  def poc_email(vendor)
    vendor.gstin_locations&.first&.poc_email
  end

  def created_by(vendor)
    vendor.created_by&.name
  end

  def pan(vendor)
    vendor.pan
  end

  def gstin(vendor)
    vendor.gstin_locations&.first&.gstin
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
    vendor.created_at.strftime('%d-%m-%Y, %H:%M %z, %A')
  end

  def gstin_location_address(vendor)
    vendor.gstin_locations&.first&.address
  end

  def address(vendor)
    vendor.gstin_locations&.first&.address
  end

  def gstin_location(vendor)
    vendor.gstin_locations&.first&.location
  end

  def default_account_number(vendor)
    self.vendor_ba = nil if self.vendor_ba != vendor.bank_accounts
    self.vendor_ba ||= vendor.bank_accounts

    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
    account = self.vendor_ba.first if account.blank?
    "\t" + (account&.account_number).to_s
  end

  def default_account_name(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
    account = self.vendor_ba.first if account.blank?
    account&.name
  end

  def default_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
    account = self.vendor_ba.first if account.blank?
    account&.ifsc
  end

  def second_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
    account = self.vendor_ba.second if account.blank?
    "\t" + (account&.account_number).to_s
  end

  def second_account_name(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
    account = self.vendor_ba.second if account.blank?
    account&.name
  end

  def second_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
    account = self.vendor_ba.second if account.blank?
    account&.ifsc
  end

  def third_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
    account = self.vendor_ba.third if account.blank?
    "\t" + (account&.account_number).to_s
  end

  def third_account_name(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
    account = self.vendor_ba.third if account.blank?
    account&.name
  end

  def third_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
    account = self.vendor_ba.third if account.blank?
    account&.ifsc
  end

  def fourth_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
    account = self.vendor_ba.fourth if account.blank?
    "\t" + (account&.account_number).to_s
  end

  def fourth_account_name(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
    account = self.vendor_ba.fourth if account.blank?
    account&.name
  end

  def fourth_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
    account = self.vendor_ba.fourth if account.blank?
    account&.ifsc
  end

  def active(vendor)
    vendor.deactivated? ? "false" : "true"
  end

  def tds_percentage(vendor)
    if vendor.vendor_tds_rates.present?
      tds_rates_list = vendor.vendor_tds_rates.collect {|vtr| vtr.tds_rates.name + "(#{vtr.tds_rates.tds})"} rescue nil
      tds_rates_list.join("| ") rescue nil
    end
  end

end