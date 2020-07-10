class BankTransfer::Vendors::Import < BankTransfer::Vendors::Base

  attr_accessor :file, :vendors_data, :result_hash, :headers

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.file = params[:file]
    self.vendors_data = ImportUtil.load_spreadsheet(file, [:name, :email, :mobile_number, :description, :pan, :gst,
                                                                  :bank_account_name_1, :bank_account_1, :ifsc_1,
                                                                  :bank_account_name_2, :bank_account_2, :ifsc_2,
                                                                  :bank_account_name_3, :bank_account_3, :ifsc_3,
                                                                  :bank_account_name_4, :bank_account_4, :ifsc_4], {skip_empty_lines: true})
    self.result_hash = []
    self.headers = retrieve_headers
  end

  def validate
    if self.vendors_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end
  end

  def process
    self.vendors_data.each_with_index do |vendor_data, index|
      self.result_hash << vendor_data.values
      vendor_data[:company_id] = user.company_id
      vendor_data[:authorized] = true
      vendor_data[:gst_registered] = true if vendor_data[:gst].present?
      retrieve_bank_accounts(vendor_data)

      # if bank accounts are not entered, throw an error right away
      if vendor_data[:bank_accounts_attributes].blank?
        self.result_hash[index] << "No bank accounts entered"
        next
      end

      vendor = YesBankVendor.new(vendor_data)
      if vendor.save
        # check if the vendor has any default bank accounts, if not make the first one default
        if vendor.bank_accounts.default_accounts.empty?
          vendor.bank_accounts.first&.update(default_account: true)
        end
        self.result_hash[index] << "Success!"
      else
        self.result_hash[index] << vendor.errors.full_messages.to_sentence
      end
    end
  end

  def success
    # self.response = Exporter::Spreadsheet.new(user, {headers: self.headers, content: self.result_hash})
    self.response = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.result_hash}, messages)
  end

  private

  def retrieve_bank_accounts(vendor_data)
    index = 1
    4.times do
      if vendor_data["bank_account_#{index}".to_sym].present? && vendor_data["ifsc_#{index}".to_sym].present? && vendor_data["bank_account_name_#{index}".to_sym].present?
        if vendor_data[:bank_accounts_attributes].blank?
          vendor_data[:bank_accounts_attributes] = []
        end
        vendor_data[:bank_accounts_attributes] << {
            account_number: vendor_data["bank_account_#{index}".to_sym],
            ifsc: vendor_data["ifsc_#{index}".to_sym],
            name: vendor_data["bank_account_name_#{index}".to_sym]
        }
        vendor_data.delete_if { |k,v| ["bank_account_#{index}".to_sym, "ifsc_#{index}".to_sym, "bank_account_name_#{index}".to_sym].include? k }
        index += 1
      else
        keys = []
        (5 - index).times do |i|
          keys += ["bank_account_#{4-i}".to_sym, "ifsc_#{4-i}".to_sym, "bank_account_name_#{4-i}".to_sym]
        end
        vendor_data.delete_if { |k,v| keys.include? k }
        break
      end
    end
  end

  def retrieve_headers
    [
        "Name",
        "Email",
        "Mobile Number",
        "Description",
        "PAN",
        "GST",
        "Bank Account Name 1",
        "Bank Account Number 1",
        "IFSC 1",
        "Bank Account Name 2",
        "Bank Account Number 2",
        "IFSC 2",
        "Bank Account Name 3",
        "Bank Account Number 3",
        "IFSC 3",
        "Bank Account Name 4",
        "Bank Account Number 4",
        "IFSC 4"
    ]
  end

end