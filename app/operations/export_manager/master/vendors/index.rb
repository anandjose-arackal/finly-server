class ExportManager::Master::Vendors::Index < ExportManager::Master::BaseSubscriber
  attr_accessor :vendor_ba

  bus ExportManager::Master::BaseMaster

  subscribe :vendors

  generators ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Synchronous
  validate :input
  fields [
                      vendor_business_name: {spreadsheet: true, pdf: false},
                      vendor_trade_name: {spreadsheet: true, pdf: false},
                      vendor_id: {spreadsheet: true, pdf: false},
                      name: {spreadsheet: true, pdf: false},
                      msme_registered: {spreadsheet: true, pdf: false},
                      msme_registration_number: {spreadsheet: true, pdf: false},
                      mobile_number: {spreadsheet: true, pdf: false},
                      email: {spreadsheet: true, pdf: false},
                      created_by: {spreadsheet: true, pdf: false},
                      pan: {spreadsheet: true, pdf: false},
                      poc_name: {spreadsheet: true, pdf: false},
                      poc_email: {spreadsheet: true, pdf: false},
                      gstin_location_address: {spreadsheet: true, pdf: false},
                      gstin: {spreadsheet: true, pdf: false},
                      tds_percentage: {spreadsheet: true, pdf: false},
                      state_code: {spreadsheet: true, pdf: false},
                      description: {spreadsheet: true, pdf: false},
                      vendor_type: {spreadsheet: true, pdf: false},
                      default_account_number: {spreadsheet: true, pdf: false},
                      default_account_ifsc: {spreadsheet: true, pdf: false},
                      second_account_number: {spreadsheet: true, pdf: false},
                      second_account_ifsc: {spreadsheet: true, pdf: false},
                      third_account_number: {spreadsheet: true, pdf: false},
                      third_account_ifsc: {spreadsheet: true, pdf: false},
                      fourth_account_number: {spreadsheet: true, pdf: false},
                      fourth_account_ifsc: {spreadsheet: true, pdf: false},
                      created_at: {spreadsheet: true, pdf: false},
                      active: {spreadsheet: true, pdf: false}
                      ]

  def input
    result = ::Vendors::Index.(user, params)

    unless result.success?
      add_message :error, result.messages[:error]
      return
    end

    vendors = result.vendors.
                            sort_for_index.
                            non_deleted.
                            authorized.
                            preload(:bank_accounts, :state_code, :created_by, :vendor_type).
                            left_joins(:gstin_locations).
                            select('
                              yes_bank_vendors.*,
                              gstin_locations.address,
                              gstin_locations.location,
                              gstin_locations.gstin,
                              gstin_locations.poc_name,
                              gstin_locations.poc_email
                            ')

    vendors
  end

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
    vendor.poc_name
  end

  def mobile_number(vendor)
    vendor.mobile_number
  end

  def email(vendor)
    vendor.email
  end

  def poc_email(vendor)
    vendor.poc_email
  end

  def created_by(vendor)
    vendor.created_by&.name
  end

  def pan(vendor)
    vendor.pan
  end

  def gstin(vendor)
    vendor.gstin
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
    vendor.address
  end

  def address(vendor)
    vendor.address
  end

  def gstin_location(vendor)
    vendor.location
  end

  def default_account_number(vendor)
    self.vendor_ba = nil if self.vendor_ba != vendor.bank_accounts
    self.vendor_ba ||= vendor.bank_accounts

    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
    account = self.vendor_ba.first if account.blank?
    account&.account_number
  end

  def default_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.first
    account = self.vendor_ba.first if account.blank?
    account&.ifsc
  end

  def second_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
    account = self.vendor_ba.second if account.blank?
    account&.account_number
  end

  def second_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.second
    account = self.vendor_ba.second if account.blank?
    account&.ifsc
  end

  def third_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
    account = self.vendor_ba.third if account.blank?
    account&.account_number
  end

  def third_account_ifsc(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.third
    account = self.vendor_ba.third if account.blank?
    account&.ifsc
  end

  def fourth_account_number(vendor)
    account = self.vendor_ba.map {|ba| ba if ba.default_account}.compact.fourth
    account = self.vendor_ba.fourth if account.blank?
    account&.account_number
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
      tds_rates_list = vendor.vendor_tds_rates.collect{|vtr| vtr.tds_rates.name + "(#{vtr.tds_rates.tds})"} rescue nil
      tds_rates_list.join("| ") rescue nil
    end
  end

end