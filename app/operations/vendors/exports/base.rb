class Vendors::Exports::Base < BaseOperation
  attr_accessor  :headers, :vendors

  def init
    ids = params[:ids] || params[:vendor_ids]
    unless ids.is_a?(Array) or ids.blank?
      ids = ids.split(',')
    end
    result = Vendors::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    # self.vendors = user.company.yes_bank_vendors.authorized.includes(:gstin_locations, :bank_accounts)
    self.vendors = result.vendors.authorized.includes(:gstin_locations, :bank_accounts)
    self.vendors = self.vendors.where(id: ids) if ids.present?
    self.headers = default_headers
  end

  def validate

  end

  class Vendors::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name, :result_file_path

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
      self.result_file_path = params[:result_file_path]
    end

  end

  private

  def default_headers
    [
        "Vendor Code",
        "Business Name",
        "Email",
        "Mobile Number",
        "Location",
        "Address",
        "PAN",
        "GSTIN",
        "State",
        "Bank Account Number",
        "IFSC",
        "MSME Reg No:"
    ]
  end


  def retrieve_data(vendor)
    gstin_location = vendor.gstin_locations.first
    bank_account = vendor.bank_accounts.first
    data_arr = []
    data_arr << vendor.vendor_id
    data_arr << vendor.business_name
    data_arr << gstin_location&.poc_email
    data_arr << gstin_location&.poc_mobile_number
    data_arr << gstin_location&.location
    data_arr << gstin_location&.address
    data_arr << vendor.pan
    data_arr << gstin_location&.gstin
    data_arr << gstin_location&.state&.name
    data_arr << bank_account&.account_number
    data_arr << bank_account&.ifsc
    data_arr << vendor.msme_registration_number
    data_arr
  end
end
