class Procurements::Payments::BulkCreateAdvance < Procurements::Payments::Base

  attr_accessor :headers, :contents, :file, :payment_mode, :scheduled_at, :policy,
                :bank_payment_request_params, :payable_amount, :bank_payment_request,
                :parsed_data, :description

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
    self.headers = [:purchase_order_number, :advance_amount]
    self.parsed_data = ImportUtil.load_spreadsheet(file, self.headers,
                                                   {skip_empty_lines: true})
    self.payment_mode = params[:payment_mode]
    self.scheduled_at = params[:scheduled_at]
    self.description = params[:description]
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)
    self.payable_amount = 0
    self.contents = []
  end

  def validate

    if self.policy.blank?
      add_message :error, "Policy cannot be blank"
      return
    end

    if self.payment_mode.blank?
      add_message :error, "Payment mode cannot be blank"
      return
    end

    errors_found = false
    self.parsed_data.each do |data|
      row_details = data.values
      po_number = data[:purchase_order_number]
      advance_amount = data[:advance_amount].to_f
      purchase_order = current_company.purchase_orders.find_by(po_number: po_number)
      vendor = purchase_order&.vendor

      if purchase_order.blank?
        row_details << "Purchase Order not found"
        self.contents << row_details
        errors_found = true
        next
      end

      # checking to make sure the PO is approved
      unless purchase_order.approved?
        row_details << "Purchase Order is not approved"
        self.contents << row_details
        errors_found = true
        next
      end

      if advance_amount.blank? || advance_amount <= 0
        row_details << "Advance amount cannot be empty or less than or equal to 0"
        self.contents << row_details
        errors_found = true
        next
      end

      if advance_amount >= purchase_order.balance_amount&.value
        row_details << "Advance cannot be greater than the balance amount in the PO"
        self.contents << row_details
        errors_found = true
        next
      end

      if vendor.bank_accounts.empty?
        row_details << "This vendor doesn't have any bank accounts"
        self.contents << row_details
        errors_found = true
        next
      end

      self.contents << row_details
      self.payable_amount += advance_amount.to_f
    end

    if errors_found
      add_message :error, "Your advance payment has a few errors, please check the same and retry"
      return
    end
  end

  def process
    self.bank_payment_request_params = parse_payment_order_params
    payment_params = parse_payment_params
    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)
    # now pass this particular bank payment request and the payments data to the
    # background operation where it will continue creating payments till the data is exhausted
    # op = BankTransfer::PaymentRequest::AddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.parsed_data})
    op = BankTransfer::PaymentRequest::AddPaymentsBackground.call(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: payment_params})

  end

  def success
    params[:bank_payment_request_id] = self.bank_payment_request.id
    Procurements::Payments::BulkCreateAdvance::SuccessPresenter.new(user, params, messages)
  end

  def failure
    exporter = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents})
    file = Tempfile.new("bulk_payment_import_errors.xls")
    open(file.path, 'wb') do |f|
      f.write exporter.generate_xls
    end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
    params[:result_file_path] = temp_file.file.url
    Procurements::Payments::BulkCreateAdvance::FailurePresenter.new(user, params, messages)
  end

  class Procurements::Payments::BulkCreateAdvance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request_id

    def init
      self.bank_payment_request_id = params[:bank_payment_request_id]
    end
  end

  class Procurements::Payments::BulkCreateAdvance::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path

    def init
      self.result_file_path = params[:result_file_path]
    end

  end

  private

  def parse_payment_order_params
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.payable_amount,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        receiving_account_type: "BankAccount",
        payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
        application: RequestStore.store[:current_app],
        currency_id: 1,
        scheduled_at: self.scheduled_at
    }
    bank_payment_request_params = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.payable_amount,
            currency_id: 1
        },
        description: self.description,
        beneficiary_type_id: 2, # this is because a purchase order will always come from a vendor
        policy_id: self.policy.id,
        payment_order_attributes: payment_order_params
    }
    return bank_payment_request_params
  end

  def parse_payment_params
    payment_params = []
    self.parsed_data.each do |data|
      po_number = data[:purchase_order_number]
      advance_amount = data[:advance_amount]
      purchase_order = current_company.purchase_orders.find_by(po_number: po_number)
      vendor = purchase_order.vendor
      bank_account = vendor.bank_accounts.first
      payment_params << {
          name: vendor.name,
          bank_account_number: bank_account.account_number,
          ifsc: bank_account.ifsc,
          original_amount: advance_amount
      }
    end
    payment_params
  end

end