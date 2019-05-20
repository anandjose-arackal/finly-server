class BankTransfer::PaymentRequest::BulkValidateFileData < BankTransfer::PaymentRequest::Base

  attr_accessor :order_details, :error_messages, :valid, :contents, :headers,
                :requested_amount, :issues, :issue_item

  class BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :order_details, :requested_amount, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.order_details = params[:order_details]
      self.requested_amount = params[:requested_amount]
      self.issues = params[:issues]
    end

  end

  class BankTransfer::PaymentRequest::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :headers, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.issues = params[:issues]
    end

  end

  def init
    self.order_details = params[:order_details]
    self.contents = []
    self.headers = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true
    self.requested_amount = 0

    self.issues = []

    Rails.logger.fatal "FROM BulkValidateFileData,\n #{params.inspect}"
    
  end

  def validate

  end

  def process
    self.order_details.each do |item|
      bank_account_no = item[:bank_account_number] || item["bank_account_number"]
      ifsc = item[:ifsc] || item["ifsc"]
      name = item[:name] || item["name"]
      business_name = item[:business_name] || item["business_name"]
      authorized = item[:authorized] || item["authorized"]
      amount = item[:original_amount]
      advance_amount = item[:advance_amount]
      gst_type_id = item[:gst_type_id]
      inclusive_of_taxes = item[:inclusive_of_taxes]
      tax = item[:tax]
      discount = item[:discount]
      tds_slab_id = item[:tds_slab_id]
      category_id = item[:category_id]
      cost_center_id = item[:cost_center_id]
      department_id = item[:department_id]
      invoice_number = item[:invoice_number]
      invoice_date = item[:invoice_date] || item[:date]
      invoice_due_date = item[:invoice_due_date] || item[:due_date]
      note = item[:note]
      external_reference_id = item[:external_reference_id]
      custom_fields_key = item[:custom_fields] || item["custom_fields"]

      # generating custom field data
      custom_fields = {}
      field_configurations = self.user.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
      field_configurations.each do |field|
        field_name = field.field_name.gsub(" ", "_").underscore
        if item[field_name.to_sym].present?
          if field.field_type_id == FieldType.id_for(:multiselect)
            custom_fields[field.id] = [item[field_name.to_sym]].flatten
          elsif field.field_type_id == FieldType.id_for(:drop_down)
            custom_fields[field.id] = item[field_name.to_sym]
          elsif field.field_type_id == FieldType.id_for(:text)
            custom_fields[field.id] = item[field_name.to_sym]
          end
        end
      end

      item[:custom_fields] = (custom_fields_key.present?) ? custom_fields_key : custom_fields
      


      self.error_messages = []
      self.issue_item = {}

      # new requirement
      # SET key as array to hold mupltiple errors
      # self.issue_item[:ifsc] = []
      # self.issue_item[:tax] = []
      # self.issue_item[:discount] = []
      # self.issue_item[:original_amount] = []
      # self.issue_item[:bank_account_number] = []

      # Check if bank account number is present
      if bank_account_no.blank?
        self.valid = false
        self.error_messages << 'Bank account not found'
        self.issue_item[:bank_account_number] = 'No bank account entered'
      end

      unless authorized
        if business_name.blank?
          self.valid = false
          self.error_messages << 'Please specify the business name to be used for the vendor'
          self.issue_item[:business_name] = 'Please specify the business name to be used for the vendor'
        end
      end


      # For now not making it mandatory to select tax type
      # if gst_type_id.blank?
      #   self.valid =false
      #   self.error_messages << "Please select a Tax Type"
      #   self.issue_item[:gst_type_id] = "Please select a Tax Type"
      # end

      # if tax.blank?
      #   self.valid =false
      #   self.error_messages << "Please select a relevant tax amount"
      #   self.issue_item[:tax] = "Please select a relevant tax amount"
      # end

      # check for format of the Bank account number
      pattern = Regexp.new(Constants::VALID_BANK_ACCOUNT)
      unless bank_account_no =~ pattern
        self.valid = false
        self.error_messages << "Invalid Bank Account Number entered"
        self.issue_item[:bank_account_number] = 'Invalid Bank Account Number entered'
      end

      # Check if the amount is present
      unless validate_amount(amount.to_s)
        self.valid = false
        self.error_messages << 'Invalid amount'
        self.issue_item[:original_amount] = 'Invalid amount'
      end

      # Check if the advance amount is present and valid
      unless advance_amount.blank? || validate_amount(advance_amount.to_s)
        self.valid = false
        self.error_messages << 'Invalid advance amount'
        self.issue_item[:advance_amount] = 'Invalid advance amount'
      end

      if advance_amount.present? && validate_amount(advance_amount.to_s)
        if advance_amount.to_f > amount.to_f
          self.valid = false
          self.error_messages << 'Advance amount is more than the original amount'
          self.issue_item[:advance_amount] = 'Advance amount is more than the original amount'
        end
      end

      # check if the ifsc is present
      if ifsc.blank?
        self.valid = false
        self.error_messages << 'IFSC cannot be blank'
        self.issue_item[:ifsc] =  'IFSC cannot be blank'
      end

      # check for format of the IFSC
      pattern = Regexp.new(Constants::VALID_IFSC)
      unless ifsc =~ pattern
        self.valid = false
        self.error_messages << "Invalid IFSC"
        self.issue_item[:ifsc] = 'Invalid IFSC'
      end

      if external_reference_id.present?
        if ::Payment.with_company_id(user.company_id).find_by(external_reference_id: external_reference_id)
          self.valid = false
          self.error_messages << "This external reference ID is already taken"
          self.issue_item[:external_reference_id] = "This external reference ID is already taken"
        end
      end

      # adding all invoice specific validations here for the payment
      # 
      # BENEFICIARY PAYMENTS WOULD NO LONGER REQUIRE INVOICES
      # 
      unless invoice_date.blank? || validate_date(invoice_date)
        self.valid = false
        self.error_messages << "Invalid invoice date"
        self.issue_item[:invoice_date] = 'Invalid invoice date'
      end

      unless invoice_due_date.blank? || validate_date(invoice_due_date)
        self.valid = false
        self.error_messages << "Invalid due date"
        self.issue_item[:invoice_due_date] = 'Invalid due date'
      end

      

      unless invoice_number.blank? || validate_invoice_number(invoice_number)
        self.valid = false
        self.error_messages << "Invoice number can only have letters, numbers, dashes, ampersand and forward slash and no other special characters"
        self.issue_item[:invoice_number] = "Invoice number can only have letters, numbers, dashes, ampersand and forward slash and no other special characters"
      end

      unless validate_rate tax, 1, amount
        self.valid = false
        self.error_messages << "Invalid tax entered"
        self.issue_item[:tax] = 'Invalid tax entered'
      end

      unless validate_rate discount, 1, amount
        self.valid = false
        self.error_messages << "Invalid discount entered"
        self.issue_item[:discount] = 'Invalid discount entered'
      end

      if self.valid
        payable_amount = calculate_tds(inclusive_of_taxes, amount, advance_amount, tds_slab_id, tax)
        # self.requested_amount += amount.to_f
        self.requested_amount += payable_amount.to_f
      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      self.contents << item.values

      #self.issue_item.each {|k, v| self.issue_item.delete(k) if v.blank?} # delete unnecessary keys which have no error
      self.issues << self.issue_item
    end
  end

  def success?
    self.valid
  end

  def failure?
    self.valid
  end

  def success
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:order_details] = self.order_details
    params[:requested_amount] = self.requested_amount
    params[:issues] = self.issues
    BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    BankTransfer::PaymentRequest::BulkValidateFileData::FailurePresenter.new(user, params, messages)
  end


  private

  def validate_rate(rate, rate_type_id, amount = nil)
    if rate.blank?
      return true
    end
    case rate_type_id
      when 1, '1'
        if rate.to_f >= 100
          return false
        end
      when 2, '2'
        return true
      else
        # do nothing?
    end
    true
  end

  def validate_date(date)
    if date.blank?
      return true
    end
    date_obj = Date.parse(date) rescue nil
    if date_obj.blank?
      return false
    end
    true
  end

  def validate_invoice_number(invoice_number)
    ( /\A[a-zA-Z0-9\/\-\#\&]*\Z/.match(invoice_number) ) ? true : false
  end

  # def validate_amount(amount)
  #   if amount.blank? || !amount.to_f&.is_a?(Numeric) || amount.to_f < 0
  #     return false
  #   end
  #   true
  # end

  def calculate_tds(inclusive_of_taxes, original_amount, advance_amount, tds_slab_id, tax)
    net_amount = 0
    if inclusive_of_taxes

      # calculate_inclusive_taxes
      gross_amount = TaxCalculationUtils.inclusive_tax_amount(original_amount.to_i, (tax.to_i))
      # calculate_tds
      tds = TdsRatesList.find(tds_slab_id).tds rescue 0
      new_gross_amount = TaxCalculationUtils.tds_amount(gross_amount, tds)
      tds_amount = gross_amount - new_gross_amount

      net_amount = original_amount.to_i - tds_amount - advance_amount.to_i

    else 

      # calculate_exclusive_taxes
      net_amount = TaxCalculationUtils.exclusive_tax_amount(original_amount.to_i, (tax.to_i))
      tax_amount = net_amount - original_amount.to_i
      # calculate_tds
      tds = TdsRatesList.find(tds_slab_id).tds rescue 0
      new_gross_amount = TaxCalculationUtils.tds_amount(original_amount.to_i, tds.to_i)
      tds_amount = original_amount.to_i - new_gross_amount

      net_amount = original_amount.to_i + tax_amount - tds_amount - advance_amount.to_i
    end
  end

  def validate_amount(amount)
    if amount.blank? || (!/\A\d+\.\d+\z/.match(amount) && !/\A\d+\z/.match(amount)) # check if blank or not a positive float or not a positive integer
      return false
    end
    true
  end

  def retrieve_header_names
    [
        "Name",
        "Account Number",
        "IFSC",
        "Sub Total",
        "Inclusive of Taxes? (Y/N)",
        "GST Type (1 - IGST ; 2 - CGST/SGST)",
        "Tax Rate",
        "Advance Amount",
        "Discount Rate",
        "TDS Slab ID",
        "Category ID",
        "Cost Center ID",
        "Department ID",
        "Invoice Number",
        "Invoice Date (dd-mm-yyyy)",
        "Due Date (dd-mm-yyyy)",
        "Narration",
    ]
  end

end