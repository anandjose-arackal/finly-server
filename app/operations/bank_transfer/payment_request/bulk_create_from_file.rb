class BankTransfer::PaymentRequest::BulkCreateFromFile < BankTransfer::PaymentRequest::Base

  attr_accessor :file, :parsed_data, :response_presenter, :errors_found,
                :result_data, :order_details, :bank_payment_request_params,
                :requested_amount, :payment_mode, :scheduled_at, :bank_payment_request,
                :headers, :contents, :validate_operation, :policy_id, :policy, :upload,
                :transfer_mode_id, :transfer_mode

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
    unless params[:policy_id].present?
        add_message :error, 'Policy cannot be blank'
        return
    end

    unless params[:scheduled_at].present?
      add_message :error, 'Please specify a scheduled date for your payment ticket.'
      return
    end

    valid_date = Date.parse(params[:scheduled_at]) rescue false 
    unless valid_date
        add_message :error, 'Invalid date provided'
        return
    end

    unless (Date.parse(params[:scheduled_at]) >= Date.today)
      add_message :error, 'Cannot create back dated payment tickets'
      return
    end
  end

  def init
    self.file = params[:file]

    unless self.file.respond_to? 'original_filename'
      add_message :error, "Please upload a properly formatted Excel Sheet."
      return
    end

    self.headers = [:name, :business_name, :bank_account_number, :ifsc, :original_amount,
               :inclusive_of_taxes, :gst_type_id, :tax_rate_id, :advance_amount, :discount, :tds_slab_id, :category_id, :cost_center_id, :department_id, :invoice_number, :invoice_date, :due_date, :note]
    payment_order_custom_fields = current_company.field_configurations.non_deleted.root_fields.with_field_parent_type(FieldParentType.id_for(:invoice))
    payment_order_custom_fields.each do |field|
      headers << field.field_name.gsub(" ", "_").underscore.to_sym
    end
    begin
      self.parsed_data = ImportUtil.load_spreadsheet_quickly(file, headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError, RuntimeError => e
      case e.class.name
      when 'RuntimeError'
        add_message :error, e.message
      else
        add_message :error, "File Format error. Please re-save your Excel sheet in Microsoft 2007 format or greater."
      end
    end

    self.payment_mode = params[:transfer_type]
    self.transfer_mode_id = params[:transfer_mode_id]
    self.transfer_mode = user.company.transfer_modes.find_by id: self.transfer_mode_id
    self.scheduled_at = params[:scheduled_at]
    self.policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: self.policy_id)
  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end

    if self.policy.blank?
      add_message :error, "Policy not found."
      return
    end

    if self.payment_mode.blank? or self.transfer_mode.blank?
      add_message :error, "Payment mode cannot be blank"
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
    # if [168, 169, 174, 175].include?(user.company.id)
    #   op = BankTransfer::PaymentRequest::Beneficiary::BeneficiaryPaymentsBackgroundOptimized.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})
    # else  
      op = BankTransfer::PaymentRequest::Beneficiary::BeneficiaryPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})
    # end
    # op = ::BankTransfer::PaymentRequest::BeneficiaryPaymentsBackground.call(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})

    # save uploaded attachment to the payment ticket
    params[:id] = self.bank_payment_request.id
    params[:bank_payment_request] = { attached_file: params[:file], description: params[:description], allow_delete: false }
    update_attachment = BankTransfer::PaymentRequest::Update::UpdateAttachment.(current_user, params)
    if update_attachment.success?
      # self.upload = update_attachment
      add_message :success, "File was saved."
    end
  end

  def success
    params[:bank_payment_request_id] = self.bank_payment_request.id
    # params[:upload] = self.upload
    BankTransfer::PaymentRequest::BulkCreateFromFile::SuccessPresenter.new(user, params, messages)
  end

  # this method should create the temporary file that can be linked in the front end
  # generate the new xlsx format
  def failure
    params[:show_file] = false
    if self.contents.present?
      result = BankTransfer::PaymentRequest::GenerateImportSample.(user, {content: self.contents})

      if result.success?
        params[:result_file_path] = result.xlsx_exporter.export_file_path
        params[:show_file] = true
      else
        add_message :error, "Some Internal Error Occurred"
      end
    end
    BankTransfer::PaymentRequest::BulkCreateFromFile::FailurePresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::BulkCreateFromFile::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request_id

    def init
      self.bank_payment_request_id = params[:bank_payment_request_id]
    end
  end

  class BankTransfer::PaymentRequest::BulkCreateFromFile::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path, :show_file

    def init
      self.result_file_path = params[:result_file_path]
      self.show_file = params[:show_file]
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
        transfer_mode_id: self.transfer_mode_id,
        scheduled_at: params[:scheduled_at],
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
        description: params[:description],
        beneficiary_type_id: 2,
        policy_id: self.policy_id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: false,
        expected_payments: self.validate_operation.order_details.count,
        ticket_type: 'beneficiary',
        transfer_mode_id: self.transfer_mode_id
    }
    bpr_attributes
  end

end