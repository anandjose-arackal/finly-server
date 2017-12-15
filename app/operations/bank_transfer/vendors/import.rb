class BankTransfer::Vendors::Import < BankTransfer::Vendors::Base

  attr_accessor :file, :vendors_data

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invaoid parameters"
    end
  end

  def init
    self.file = params[:file]
    self.vendors_data = ImportUtil.load_spreadsheet(file, [:name, :email, :mobile_number, :description,
                                                                  :pan, :gst], {skip_empty_lines: true})
    self.result_hash = []
  end

  def process
    self.vendors_data.each_with_index do |vendor_data, index|
      self.result_hash << vendor_data.values
      vendor_data[:company_id] = user.company_id
      vendor = YesBankVendor.new(vendor_data)
      if vendor.save
        self.result_hash[index] += "Success!"
      else
        self.result_hash[index] += vendor.errors.full_messages
      end
    end
  end

  def success

  end

end