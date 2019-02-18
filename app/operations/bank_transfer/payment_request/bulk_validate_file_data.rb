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
    # binding.pry
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
      amount = item[:original_amount]
      gst_type_id = item[:gst_type_id]
      inclusive_of_taxes = item[:inclusive_of_taxes]
      tax = item[:tax]
      discount = item[:discount]
      tds_slab_id = item[:tds_slab_id]
      category_id = item[:category_id]
      cost_center_id = item[:cost_center_id]
      department_id = item[:department_id]
      # invoice_number = item[:invoice_number]
      # invoice_date = item[:invoice_date]
      # due_date = item[:due_date]
      note = item[:note]

      # generating custom field data
      custom_fields = {}
      field_configurations = self.user.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
      field_configurations.each do |field|
        field_name = field.field_name.gsub(" ", "_").underscore
        if item[field_name.to_sym].present?
          if field.field_type_id == FieldType.id_for(:multiselect)
            custom_fields[field.id] = [item[field_name.to_sym]]
          elsif field.field_type_id == FieldType.id_for(:drop_down)
            custom_fields[field.id] = item[field_name.to_sym]
          end
        end
      end

      item[:custom_fields] = custom_fields
      


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

      # check for format of the Bank account number
      pattern = Regexp.new(Constants::VALID_BANK_ACCOUNT)
      unless bank_account_no =~ pattern
        self.valid = false
        self.error_messages << "Invalid Bank Account Number entered"
        self.issue_item[:bank_account_number] = 'Invalid Bank Account Number entered'
      end

      # Check if the amount is present
      unless validate_amount(amount)
        self.valid = false
        self.error_messages << 'Invalid amount'
        self.issue_item[:original_amount] = 'Invalid amount'
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

      
      # adding all invoice specific validations here for the payment
      # 
      # BENEFICIARY PAYMENTS WOULD NO LONGER REQUIRE INVOICES
      # 
      # unless validate_date invoice_date
      #   self.valid = false
      #   self.error_messages << "Invalid invoice date"
      #   self.issue_item[:invoice_date] = 'Invalid invoice date'
      # end

      # unless validate_date due_date
      #   self.valid = false
      #   self.error_messages << "Invalid due date"
      #   self.issue_item[:due_date] = 'Invalid due date'
      # end

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
        self.requested_amount += amount.to_f
      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      self.contents << item.values

      #self.issue_item.each {|k, v| self.issue_item.delete(k) if v.blank?} # delete unnecessary keys which have no error
      self.issues << self.issue_item
    end
    puts "self.issues", self.issues.inspect
    # binding.pry
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

  # def validate_amount(amount)
  #   if amount.blank? || !amount.to_f&.is_a?(Numeric) || amount.to_f < 0
  #     return false
  #   end
  #   true
  # end

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