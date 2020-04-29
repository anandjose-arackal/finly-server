class BankTransfer::PaymentRequest::UtilityBills::CreateUtilityBillsTicket < BankTransfer::PaymentRequest::UtilityBills::Base

  attr_accessor :scheduled_at, :payment_mode, :policy_id, :bbps_bills,
                :bank_payment_request, :payable_amount, :description,
                :payment_request_params, :policy, :bank_payment_request_params, :payable_amounts, :requested_amount,
                :payments, :transfer_mode_id, :transfer_mode, :ticket_type


  class BankTransfer::PaymentRequest::UtilityBills::CreateUtilityBillsTicket::UtilityBillsPresenter < BaseOperation::BasePresenter::SuccessPresenter

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
    if params[:bbps_bill_id].blank?
      add_message :error, 'No Invoices sent for processing.'
      return
    end
    unless params[:policy_id].present?
      add_message :error, 'Policy cannot be blank'
      return
    end
    unless params[:scheduled_at].present?
      add_message :error, 'Please specify a scheduled date for your payment ticket'
      return
    end

    valid_date = Date.parse(params[:scheduled_at]) rescue false
    unless valid_date
      add_message :error, 'Invalid date provided'
      return
    end

    unless Date.parse(params[:scheduled_at]) && (Date.parse(params[:scheduled_at]) >= Date.today)
      add_message :error, 'Cannot create back dated payment tickets'
      return
    end
  end

  def init
    self.requested_amount = 0
    ids = params[:bbps_bill_id]

    self.bbps_bills = current_company.bbps_bills.with_id(ids)
    self.requested_amount = Amount.where("id in (?)", self.bbps_bills.filter_status("payables").pluck(:total_amount_id)).sum(:value)

    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    self.transfer_mode_id = params[:transfer_mode_id] || current_company.transfer_modes.find_by(mode_id: TransferMode.find_by(name: params[:payment_mode].downcase))&.id
    self.transfer_mode = user.company.transfer_modes.find_by id: self.transfer_mode_id
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)
    self.description = params[:description]
    self.ticket_type = "utility_bill"
  end

  def validate
    if self.bbps_bills.empty?
      add_message :error, "Nothing to add"
      return
    end

    invalid_bills = []
    self.bbps_bills.map { |bill| invalid_bills << bill unless bill.payable?}

    if invalid_bills.present?
      add_message :error, "These bills with ID, \"#{self.bbps_bills.map(&:sequence_id).compact.join(", ")}\", cannot be paid right now"
      return
    end

    if self.policy.blank?
      add_message :error, "Policy not found."
      return
    end

    if self.payment_mode.blank?
      add_message :error, "Payment mode cannot be blank"
      return
    end

  end

  def process
    self.payment_request_params = bank_payment_request_params
    self.bank_payment_request = user.bank_payment_requests.build(self.payment_request_params)
    if self.bank_payment_request.save

      # Create Document Level Reviewer Mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.bank_payment_request.reload

      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        self.bank_payment_request.destroy
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end

      self.bbps_bills.update_all(status_id: BbpsBillStatus.id_for(:payment_ticket_created))
      payment_params = initialize_payment_objects
      op = BankTransfer::PaymentRequest::UtilityBills::UtilityBillsTicketBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: payment_params, bbps_bill_ids: self.bbps_bills.pluck(:id), ticket_type: ticket_type})
    else
      add_message :error, self.bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment Ticket for utility bills created"
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::UtilityBills::CreateUtilityBillsTicket::UtilityBillsPresenter.new(user, params, messages)
  end


  private

  def initialize_payment_objects
    payment_params = []
    self.bbps_bills.each do |bill|
      initiating_account = current_company.billing_account
      receiving_account = bill.subscription.biller
      payment_params << {
          account_id: receiving_account.id,
          requested_amount: bill.amount_value,
          payment_type_id: PaymentType.id_for(:credit),
          application: RequestStore.store[:current_app],
          receiving_user_type: bill.subscription.class.name,
          receiving_user_id: bill.subscription.id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: initiating_account&.class&.name,
          initiating_account_id: initiating_account&.id,
          receiving_account_type: receiving_account.class.name,
          receiving_account_id: receiving_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:utility_bill_payment),
          payment_mode: self.bank_payment_request.payment_mode,
          transfer_mode_id: self.transfer_mode_id,
          amount_attributes: {
              value: bill.amount_value,
              currency_id: Currency.first.id
          },
          note: bill.name,
          category_id: bill.category_id,
          cost_center_id: bill.cost_center_id,
          department_id: bill.department_id,
          date: DateUtils.local_date,
          parent_type: bill&.class.name,
          parent_id: bill&.id
      }
    end
    # self.payments = self.bank_payment_request.payment_order.payments.build(payment_params)
    payment_params
  end

  def bank_payment_request_params
    # the initiating account is always the virtual account here
    initiating_account = current_company.billing_account
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        transfer_mode_id: self.transfer_mode_id,
        initiating_account_type: initiating_account&.class&.name,
        receiving_account_type: "BbpsBiller",
        payment_purpose_id: PaymentPurpose.id_for(:utility_bill_payment),
        application: RequestStore.store[:current_app],
        currency_id: 1,
        scheduled_at: self.scheduled_at
    }
    bank_payment_request_params = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        transfer_mode_id: self.transfer_mode_id,
        description: self.description,
        policy_id: self.policy&.id,
        payment_order_attributes: payment_order_params,
        ticket_type: ticket_type
    }
    return bank_payment_request_params
  end

end