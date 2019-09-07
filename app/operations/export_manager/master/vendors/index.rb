class ExportManager::Master::Vendors::Index < ExportManager::Master::BaseSubscriber

  bus ExportManager::Master::BaseMaster

  subscribe :vendors

  generators ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Synchronous
  validate :input
  fields [
                      vendor_business_name: {spreadsheet: true, pdf: false},
                      vendor_id: {spreadsheet: true, pdf: false},
                      authorized: {spreadsheet: true, pdf: false},
                      name: {spreadsheet: true, pdf: false},
                      mobile_number: {spreadsheet: true, pdf: false},
                      email: {spreadsheet: true, pdf: false},
                      created_by: {spreadsheet: true, pdf: false},
                      pan: {spreadsheet: true, pdf: false},
                      address: {spreadsheet: true, pdf: false},
                      gstin: {spreadsheet: true, pdf: false},
                      state_code: {spreadsheet: true, pdf: false},
                      description: {spreadsheet: true, pdf: false},
                      vendor_type: {spreadsheet: true, pdf: false},
                      default_account_number: {spreadsheet: true, pdf: false},
                      default_account_ifsc: {spreadsheet: true, pdf: false},
                      created_at: {spreadsheet: true, pdf: false}
                      ]

  def input
    params[:beneficiary_type] = 2
    result = BankTransfer::AccountOwners::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end

    ids = params[:ids] || params[:vendor_ids] || params[:filter_ids]
    unless ids.is_a?(Array) or ids.blank?
      ids = ids.split(',')
    end

    vendors = result.account_owners
    vendors = vendors.where(id: ids) if ids.present?
    vendors
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
    vendor.mobile_number
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
    vendor.created_at
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