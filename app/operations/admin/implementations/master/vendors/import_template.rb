class Admin::Implementations::Master::Vendors::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'vendors.import_template'
  headers [
              :id,
              :name,
              :vendor_type,
              :vendor_id,
              :business_name,
              :mobile_number,
              :email,
              :pan,
              :state,
              :description,
              :address,
              :gstin,
              :gst_location,
              :vendor_bank_account_name,
              :account_number,
              :ifsc,
              :destroy
          ]

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
