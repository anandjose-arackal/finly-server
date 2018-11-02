class BankTransfer::PaymentRequest::BulkValidateFileData < BankTransfer::PaymentRequest::Base

  attr_accessor :order_details, :error_messages, :valid, :contents, :header,
                :requested_amount

  class BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :header

    def init
      self.contents = params[:contents]
      self.header = params[:header]
      self.order_details = params[:order_details]
    end

  end

  class BankTransfer::PaymentRequest::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :header

    def init
      self.contents = params[:contents]
      self.header = params[:header]
    end

  end

  def init
    self.order_details = params[:order_details]
    self.contents = []
    self.header = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true
    self.requested_amount = 0
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
      invoice_number = item[:invoice_number]
      invoice_date = item[:invoice_date]
      due_date = item[:due_date]
      note = item[:note]


      self.error_messages = []
      # Check if bank account number is present
      if bank_account_no.blank?
        self.valid = false
        self.error_messages << 'Bank account not found'
      end

      # Check if the amount is present
      unless validate_amount(amount)
        self.valid = false
        self.error_messages << 'Invalid amount'
      end

      # check if the ifsc is present
      if ifsc.blank?
        self.valid = false
        self.error_messages << 'IFSC cannot be blank'
      end

      # check for format of the IFSC
      pattern = Regexp.new(Constants::VALID_IFSC)
      unless ifsc =~ pattern
        self.valid = false
        self.error_messages << "Invalid IFSC"
      end

      # adding all invoice specific validations here for the payment
      unless validate_date invoice_date
        self.valid = false
        self.error_messages << "Invalid invoice date"
      end

      unless validate_date due_date
        self.valid = false
        self.error_messages << "Invalid due date"
      end

      unless validate_rate tax, 1, amount
        self.valid = false
        self.error_messages << "Invalid tax entered"
      end

      unless validate_rate discount, 1, amount
        self.valid = false
        self.error_messages << "Invalid discount entered"
      end

      unless validate_rate advance, 1, advance
        self.valid = false
        self.error_messages << "Invalid advance entered"
      end

      if self.valid
        self.requested_amount += amount.to_f
      end

      item[:errors] = self.error_messages.to_sentence

      self.contents << item.values
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
    params[:header] = self.header
    params[:order_details] = self.order_details
    params[:requested_amount] = self.requested_amount
    BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:header] = self.header
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

  def validate_amount(amount)
    if amount.blank? || !amount.to_f&.is_a?(Numeric) || amount.to_f < 0
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