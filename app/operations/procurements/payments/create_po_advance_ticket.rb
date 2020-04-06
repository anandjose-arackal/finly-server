# This will create a payment ticket for advance payment for an already existing puchase order which is DEFINITELY LINKED to a procurement
# This will generate a new payment order and a new payment ticket

class Procurements::Payments::CreatePoAdvanceTicket < Procurements::Payments::Base

  attr_accessor :purchase_order, :scheduled_at, :payment_mode, :policy_id, :policy, :payments, :contents,
                :description, :bank_payment_request, :total_advance_amount,
                :payment_request_params, :receiving_account, :bank_payment_request_params,
                :requested_amount, :all_purchase_orders, :transfer_mode_id, :transfer_mode

  class Procurements::Payments::CreatePoAdvanceTicket::BankPaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
    end

  end

  def pre_validate
      if user.blank?
        add_message :error, 'User not found'
        return
      end
      if params.blank?
        add_message :error, 'No params sent at all.'
        return
      end
      if params[:po_advance_attributes].blank?
        add_message :error, 'No Purchase Orders sent for advance payment processing.'
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
    # params[:policy_id] = 4
    # params[:purchase_order_id] = 1733
    # params[:scheduled_at] = "2019-02-28"
    # params[:payment_mode] = 'neft'
    # params[:po_advance_attributes] = [{purchase_order_id: 1733, advance_amount: '300', advance_tds_slab_id: '1' }]
    id = params[:id] || params[:purchase_order_id] || params[:po_id]
    self.scheduled_at = params[:scheduled_at]
    self.description = params[:description]
    self.payment_mode = params[:payment_mode]
    self.transfer_mode_id = params[:transfer_mode_id]
    self.transfer_mode = user.company.transfer_modes.find_by id: self.transfer_mode_id
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)
    # self.total_advance_amount = params[:total_advance_amount]
    # self.receiving_account = user.company.bank_accounts.find_by(id: params[:receiving_account_id])

    # self.payments = self.purchase_order.advance_payments.where(id: params[:advance_payment_id])
    self.payments = []

    # params[:po_advance_attributes].each do |po_advance|
    #   id = params[:id] || params[:purchase_order_id] || params[:po_id]
    #   self.purchase_order = user.company.purchase_orders.find_by(id: id)
    #   params[:department_id] = self.purchase_order.department_id 

    #   yes = YesBankVendor.find(po_advance[:vendor_id])
    #   ba = yes.bank_accounts.where(id: po_advance[:bank_account_id])
    #   po_advance[:bank_account_number] = ba.pluck(:account_number).first
    #   po_advance[:ifsc] = ba.pluck(:ifsc).first

    # end

    self.total_advance_amount = 0
    self.contents = []

    # self.requested_amount = self.payments.sum_amounts
  end

  def validate

    if self.policy.blank?
      add_message :error, "Policy cannot be blank"
      return
    end

    if self.payment_mode.blank? or self.transfer_mode.blank?
      add_message :error, "Payment mode cannot be blank"
      return
    end

    errors_found = false
    params[:po_advance_attributes].each do |po_advance|
      row_details = []
      po_id = po_advance[:purchase_order_id]
      advance_amount = po_advance[:advance_amount].to_f
      purchase_order = user.company.purchase_orders.find_by(id: po_id)
      vendor = purchase_order&.vendor

      if purchase_order.blank?
        row_details << "Purchase Order not found"
        self.contents << row_details
        errors_found = true
        next
      end

      unless purchase_order.advance_can_be_paid?
        row_details << "Purchase Order id #{purchase_order.id} is already linked to a payment ticket."
        self.contents << row_details
        errors_found = true
        next
      end

      # checking to make sure the PO is approved
      unless purchase_order.approved? || purchase_order.auto_approved? || purchase_order.sent_to_vendor? || purchase_order.vendor_confirmed?
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

      if purchase_order.bank_account.blank?
        row_details << "This PO advance(# #{purchase_order.id}) needs a bank account associated with it. Please update those details by going to the purchase order show page."
        self.contents << row_details
        errors_found = true
        next
      end

      if advance_amount > (purchase_order.balance_amount&.value + 1) # adding a buffer to account for roundoff amount
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

      if purchase_order.bank_account&.disabled
        row_details << "This vendor has a bank account which is disabled. Payment can only be processed to active bank accounts."
        self.contents << row_details
        errors_found = true
        next
      end

      self.contents << row_details
      self.total_advance_amount += advance_amount.to_f
    end

    if errors_found
      add_message :error, self.contents.flatten #"Your advance payment has a few errors, please check the same and retry"
      return
    end

    po_ids = params[:po_advance_attributes].pluck(:purchase_order_id)
    self.all_purchase_orders = user.company.purchase_orders.where(id: po_ids)
  end

  # to be used when PO can have multiple advance payments in future
  #
  # def process
  #   # self.payment_request_params = bank_payment_request_params
  #   # self.bank_payment_request = user.bank_payment_requests.build(self.payment_request_params)
  #   # if self.bank_payment_request.save
  #   #   # any changes to be made here? #todo
  #   # else
  #   #   add_message :error, self.bank_payment_request.errors.full_messages
  #   # end

  #   # if the validation of the data is successful, it will create a payment order and
  #   # asynchronously add payments to it one by one
  #   self.bank_payment_request_params = parse_payment_order_data
  #   self.bank_payment_request = user.bank_payment_requests.build(self.bank_payment_request_params)
  #   if self.bank_payment_request.save
  #     # when bpr is created, we then update each advance payment with the payment order id
  #     # this data is then fed back to the payment order as payments_attributes
  #     # bpr is then updated with the new payment_order_attributes

  #     # handle updation of individual payments
  #     bpr_id = self.bank_payment_request.id
  #     payment_order_id = self.bank_payment_request.payment_order.id
  #     self.payments.each do |payment|
  #       payment.update(payment_order_id: payment_order_id)
  #     end

  #     # self.bank_payment_request.payment_order.payments_attributes = self.payments
  #     # self.bank_payment_request.payment_order_attributes = self.bank_payment_request.payment_order


  #   else
  #     add_message :error, self.bank_payment_request.errors.full_messages
  #   end

  # end

  def process
    self.bank_payment_request_params = parse_payment_order_data
    payment_params = parse_payment_params
    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)

    if self.bank_payment_request
      self.all_purchase_orders.update_all(advance_amount_status_id: AdvanceAmountStatus.id_for(:pending))

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
      op = Procurements::Payments::PoAdvancePaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: payment_params})
      # op = BankTransfer::PaymentRequest::AddPaymentsBackground.call(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: payment_params})
    else
      add_message :error, self.bank_payment_request.errors.full_message
    end
  end

  def post_process
    add_message :success, "Payment Ticket created."

  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    Procurements::Payments::CreatePoAdvanceTicket::BankPaymentRequestPresenter.new(user, params, messages)
  end


  private

  def parse_payment_order_data
    initiating_account = retrieve_initiating_account(user.company)
    policy = user.enforce_policy_enabled? ? user.policies.non_default.first : user.policies.default.first
    payment_order_attributes = {
        initiating_user_id: user.id,
        payment_order_status_id: PaymentOrderStatus.id_for(:creation_in_progress),
        company_id: user.company_id,
        amount_requested_attributes: {
            # value: self.total_advance_amount,
            value: 0,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        transfer_mode_id: self.transfer_mode_id,
        initiating_account_type: initiating_account&.class&.name,
        receiving_account_type: BankAccount.name,
        payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
        application: "vp",
        currency_id: Currency.first.id,
        scheduled_at: self.scheduled_at,
        api_initiated: false
    }
    bpr_attributes = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            # value: self.total_advance_amount,
            value: 0,
            currency_id: 1
        },
        beneficiary_type_id: 2,
        # policy_id: policy&.id,
        policy_id: self.policy&.id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: false,
        description: self.description,
        expected_payments: self.all_purchase_orders.count,
        ticket_type: 'purchase_order',
        transfer_mode_id: self.transfer_mode_id
    }
    bpr_attributes
  end

  def parse_payment_params
    payment_params = []
    params[:po_advance_attributes].each do |po_advance|
      po_id = po_advance[:purchase_order_id]
      advance_amount = po_advance[:advance_amount]
      # purchase_order = current_company.purchase_orders.find_by(po_number: po_number)
      purchase_order = user.company.purchase_orders.find_by(id: po_id)
      vendor = purchase_order.vendor
      # bank_account = vendor.bank_accounts.where(default_account: true).first
      bank_account = purchase_order.bank_account
      set_payment_params = {
          name: vendor.name,
          bank_account_number: bank_account&.account_number,
          ifsc: bank_account.ifsc,
          requested_amount: advance_amount,
          account_id: bank_account.id,
          purchase_order_id: purchase_order&.id,
          payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
          parent_type: purchase_order&.class.name,
          parent_id: purchase_order&.id,
          advance_tds_slab_id: po_advance[:advance_tds_slab_id],
          transfer_mode_id: self.transfer_mode_id,
          note: purchase_order&.procurement&.name,
          location_id: purchase_order&.location_id
      }

      unless purchase_order&.cost_allocation_items
        set_payment_params[:department_id] = purchase_order&.department_id
        set_payment_params[:cost_center_id] = purchase_order&.cost_center_id
      end
      payment_params << set_payment_params

    end
    payment_params
  end

  def retrieve_initiating_account(company)
    case company&.feature_subscription&.bank_service_provider
    when "YES"
      initiating_account = user.company.yes_bank_company_account
    when "ICICI"
      initiating_account = user.company.icici_bank_company_account
    when "KOTAK"
      initiating_account = user.company.kotak_bank_company_account
    else
      initiating_account = user.company.yes_bank_company_account
    end
    initiating_account
  end

end