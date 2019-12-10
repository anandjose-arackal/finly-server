# this operation will create an advance payment ticket from an existing purchae order
# which will be wrapped within a payment order and can be processed separately
class Procurements::Payments::CreateAdvance < Procurements::Payments::Base
  attr_accessor :purchase_order, :scheduled_at, :payment_mode, :policy, :policy_id,
                :description, :bank_payment_request, :advance_amount,
                :payment_request_params, :transfer_mode_id, :transfer_mode

  class Procurements::Payments::CreateAdvance::BankPaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

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
    id = params[:id] || params[:purchase_order_id] || params[:po_id]
    self.purchase_order = user.company.purchase_orders.find_by(id: id)
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    self.transfer_mode_id = params[:transfer_mode_id]
    self.transfer_mode = user.company.transfer_modes.find_by id: self.transfer_mode_id
    self.description = params[:description]

    params[:filter_role_id] = UserRole.id_for(:bank_payment_request_initiator)
    result = Policy::VendorPayments::Index.(user, params)
    unless result.success?
      add_message :error, "You dont seem to be part of any policy. Please contact your company admin."
      return
    end
    self.policy = result.policies.find_by(id: params[:policy_id]) rescue Policy::none
    self.policy_id = params[:policy_id]
    self.advance_amount = self.purchase_order.advance_amount&.value.to_f
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase Order not found"
    end

    if self.payment_mode.blank?
      add_message :error, "Payment mode cannot be blank"
      return
    end

    if self.policy.blank?
      add_message :error, "Policy not found. Are you a payment ticket initiator for the selected policy?"
      return
    end

    unless self.purchase_order.advance_can_be_paid?
      add_message :error, "You cannot credit this advance as it already has a unprocessed payment associated with it"
      return
    end

    # checking to make sure the PO is approved
    unless self.purchase_order.approved? || self.purchase_order.auto_approved? || self.purchase_order.sent_to_vendor? || self.purchase_order.vendor_confirmed?
      add_message :error, "Purchase Order is not approved"
      return
    end

    if self.advance_amount.blank? || self.advance_amount <= 0
      add_message :error, "Advance amount cannot be empty or less than or equal to 0"
      return
    end

    if self.purchase_order.bank_account.blank?
      add_message :error, "This Purchase Order needs a bank account associated with it. Please update those details."
      return
    end

    if self.advance_amount > (self.purchase_order.balance_amount&.value + 1) # adding a buffer to account for roundoff amount
      add_message :error, "Advance cannot be greater than the balance amount in the PO"
      return
    end

    if self.purchase_order.vendor&.bank_accounts.empty?
      add_message :error, "This vendor doesn't have any bank accounts"
      return
    end
  end

  def process
    self.payment_request_params = bank_payment_request_params
    self.bank_payment_request = user.bank_payment_requests.build(self.payment_request_params)
    if self.bank_payment_request.save
      # any changes to be made here? #todo
      
      # Create Document Level Reviewer Mapping
      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.bank_payment_request.reload

      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
      unless document_reviewer_mappings_op.success?
        self.bank_payment_request.destroy
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end
      self.purchase_order.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:initiated))
    else
      add_message :error, self.bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment order created"
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    Procurements::Payments::CreateAdvance::BankPaymentRequestPresenter.new(user, params, messages)
  end


  private

  def bank_payment_request_params
    payment_params = [{
        payment_type_id: PaymentType.id_for(:credit),
        application: RequestStore.store[:current_app],
        receiving_user_type: self.purchase_order.bank_account&.account_owner&.class&.name,
        receiving_user_id: self.purchase_order.bank_account&.account_owner_id,
        initiating_user_type: "User",
        initiating_user_id: user.id,
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        initiating_account_id: user.company.yes_bank_company_account&.id,
        receiving_account_type: "BankAccount",
        receiving_account_id: self.purchase_order.bank_account&.id,
        payment_status_id: PaymentStatus.id_for(:pending_approval),
        payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
        payment_mode: self.payment_mode,
        transfer_mode_id: self.transfer_mode_id,
        amount_attributes: {
            value: self.advance_amount,
            currency_id: Currency.first.id
        },
        note: self.description,
        category_id: self.purchase_order.category_id,
        department_id: self.purchase_order.department_id,
        date: DateUtils.local_date,
        purchase_order_id: self.purchase_order.id,
        parent_type: self.purchase_order.class.name,
        parent_id: self.purchase_order.id
    }]
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.advance_amount,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        transfer_mode_id: self.transfer_mode_id,
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        receiving_account_type: "BankAccount",
        payment_purpose_id: PaymentPurpose.id_for(:advance_against_purchase_order),
        application: RequestStore.store[:current_app],
        currency_id: 1,
        scheduled_at: self.scheduled_at,
        payments_attributes: payment_params
    }
    bank_payment_request_params = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:open),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.advance_amount,
            currency_id: 1
        },
        description: self.description,
        beneficiary_type_id: 2, # this is because a purchase order will always come from a vendor
        policy_id: self.policy_id,
        payment_order_attributes: payment_order_params,
        expected_payments: 1,
        ticket_type: 'purchase_order',
        transfer_mode_id: self.transfer_mode_id
    }
    return bank_payment_request_params
  end

end