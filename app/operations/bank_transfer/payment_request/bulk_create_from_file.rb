class BankTransfer::PaymentRequest::BulkCreateFromFile < BankTransfer::PaymentRequest::Base

  attr_accessor :file, :parsed_data, :response_presenter, :errors_found,
                :result_data, :order_details, :bank_payment_request_params,
                :requested_amount, :payment_mode, :scheduled_at, :bank_payment_request,
                :headers, :contents, :validate_operation, :policy_id

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
               :inclusive_of_taxes, :gst_type_id, :tax, :discount, :tds_slab_id, :category_id, :cost_center_id, :department_id, :invoice_number, :invoice_date, :due_date, :note]
    payment_order_custom_fields = current_company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    payment_order_custom_fields.each do |field|
      headers << field.field_name.gsub(" ", "_").underscore
    end
    self.parsed_data = ImportUtil.load_spreadsheet(file, headers,
                                                   {skip_empty_lines: true})
    self.payment_mode = params[:transfer_type]
    self.scheduled_at = params[:scheduled_at]
    self.policy_id = params[:policy_id]
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    self.validate_operation = BankTransfer::PaymentRequest::BulkValidateFileData.(user, {order_details: self.parsed_data})
    if validate_operation.success?
      self.requested_amount = validate_operation.requested_amount
    else
      self.contents = validate_operation.contents
      self.headers = validate_operation.headers
      add_message :error, "Some of the payments have errors, please check the downloaded file to resolve them"
    end

  end

  def process
    # if the validation of the data is successful, it will create a payment order and
    # asynchronously add payments to it one by one
    self.bank_payment_request_params = parse_payment_order_data
    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)

    # Create Document Level Reviewer Mapping
    # For setting level specific reviewers from reviewal chain for a document
    params[:reviewal_document] = self.bank_payment_request.reload

    document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
    unless document_reviewer_mappings_op.success?
      self.bank_payment_request.destroy
      add_message :error, document_reviewer_mappings_op.messages[:error]
      return
    end

    # now pass this particular bank payment request and the payments data to the
    # background operation where it will continue creating payments till the data is exhausted
    op = BankTransfer::PaymentRequest::AddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})
    # op = BankTransfer::PaymentRequest::AddPaymentsBackground.call(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})

  end

  def success
    params[:bank_payment_request_id] = self.bank_payment_request.id
    BankTransfer::PaymentRequest::BulkCreateFromFile::SuccessPresenter.new(user, params, messages)
  end

  # this method should create the temporary file that can be linked in the front end
  def failure
    exporter = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents})
    file = Tempfile.new("bulk_payment_import_errors.xls")
    open(file.path, 'wb') do |f|
      f.write exporter.generate_xls
    end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
    params[:result_file_path] = temp_file.file.url
    BankTransfer::PaymentRequest::BulkCreateFromFile::FailurePresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::BulkCreateFromFile::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request_id

    def init
      self.bank_payment_request_id = params[:bank_payment_request_id]
    end
  end

  class BankTransfer::PaymentRequest::BulkCreateFromFile::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path

    def init
      self.result_file_path = params[:result_file_path]
    end
  end

  private

  def parse_payment_order_data
    payment_order_attributes = {
        initiating_user_id: user.id,
        payment_order_status_id: PaymentOrderStatus.id_for(:creation_in_progress),
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
        status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
        # controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        beneficiary_type_id: 2,
        policy_id: self.policy_id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: false
    }
    bpr_attributes
  end

end