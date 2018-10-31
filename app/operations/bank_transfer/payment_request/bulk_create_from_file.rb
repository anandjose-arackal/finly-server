class BankTransfer::PaymentRequest::BulkCreateFromFile < BankTransfer::PaymentRequest::Base

  attr_accessor :file, :parsed_data, :response_presenter, :errors_found,
                :result_data, :order_details, :bank_payment_request_params,
                :requested_amount, :payment_mode

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    self.file = params[:file]
    headers = [:name, :bank_account_number, :ifsc, :original_amount,
               :inclusive_of_taxes, :gst_type_id, :tax, :discount, :tds_slab_id, :category_id, :department_id, :cost_center_id, :invoice_number, :invoice_date, :due_date, :note]
    payment_order_custom_fields = current_company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    payment_order_custom_fields.each do |field|
      headers << field.field_name.gsub(" ", "_").underscore
    end
    self.parsed_data = ImportUtil.load_spreadsheet(file, headers,
                                                   {skip_empty_lines: true})
    self.payment_mode = params[:payment_mode]
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    op = BankTransfer::PaymentRequest::BulkValidateFileData.(user, {order_details: self.parsed_data})

    if op.success?
      self.requested_amount = op.requested_amount
    else
      self.contents = op.contents
      self.header = op.header
    end

  end

  def process
    # if the validation of the data is successful, it will create a payment order and
    # asynchronously add payments to it one by one
    self.bank_payment_request_params = parse_payment_order_data
    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)

    # now pass this particular bank payment request and the payments data to the
    # background operation where it will continue creating payments till the data is exhausted
  end

  # this method should create the temporary file that can be linked in the front end
  def failure

  end

  private

  def parse_payment_order_data
    payment_order_attributes = {
        initiating_user_id: user.id,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        initiating_account_type: YesBankCompanyAccount.name,
        receiving_account_type: BankAccount.name,
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        application: "vp",
        currency_id: Currency.first.id,
        api_initiated: false
    }
    bpr_attributes = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:open),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        beneficiary_type_id: 2,
        policy_id: user.company.policies.default.first.id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: false
    }
    bpr_attributes
  end

end