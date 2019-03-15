# This will create a payment ticket for invoice which are unpaid or partially paid
# This will generate a new payment order and a new payment ticket
# all individual payment object creation happoens in the background

class BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket < BankTransfer::PaymentRequest::Base

  # attr_accessor :purchase_order, :scheduled_at, :payment_mode, :policy_id, :policy, :payments, :contents,
  #               :description, :bank_payment_request, :total_advance_amount,
  #               :payment_request_params, :receiving_account, :bank_payment_request_params,
  #               :requested_amount, :all_purchase_orders
  attr_accessor :inward_invoices, :payments, :bank_payment_request, :payable_amounts,
                :invoices_params, :requested_amount, :scheduled_at, :payment_mode, :policy, :bank_payment_request_params

  class BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket::BankPaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

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
      if params[:invoices].blank?
        add_message :error, 'No Invoices sent for processing.'
        return
      end
  end

  def init
    params[:policy_id] = 4
    # params[:purchase_order_id] = 1733
    params[:scheduled_at] = "2019-02-28"
    params[:payment_mode] = 'neft'
    params[:invoices] = [{invoice_id: 40343, payable_amount: '1' }]
    self.payable_amounts = {}
    self.requested_amount = 0
    ids = []
    self.invoices_params = params[:invoices]
    self.invoices_params.each do |param|
      ids << param[:invoice_id]
      self.payable_amounts[param[:invoice_id]&.to_i] = param[:payable_amount].to_f
    end
    self.inward_invoices = user.company.inward_invoices.with_id(ids)
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)
  end

  def validate
    if self.inward_invoices.empty?
      add_message :error, "Nothing to add"
      return
    end

    # todo - add conditions to select how much of the invoice will be paid in this payment
    self.payable_amounts.each do |invoice_id, payable_amount|
      invoice = self.inward_invoices.find_by(id: invoice_id)
      remaining_amount = (invoice.balance_due&.value.to_f - invoice.payments.successful.joins(:amount).sum(:value))
      if remaining_amount.blank?
        next
      end
      if payable_amount > remaining_amount
        add_message :error, "You cannot pay more than the remaining amount in an invoice"
      end
      self.requested_amount += payable_amount
    end
  end

  def process
    self.bank_payment_request_params = parse_payment_order_data
    payment_params = parse_payment_params
    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)

    if self.bank_payment_request
      self.inward_invoices.update_all(invoice_status_id: InwardInvoiceStatus.id_for(:pending))
      # now pass this particular bank payment request and the payments data to the
      # background operation where it will continue creating payments till the data is exhausted
      op = BankTransfer::PaymentRequest::NewAddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: payment_params, ticket_type: 'invoice'})
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
    BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket::BankPaymentRequestPresenter.new(user, params, messages)
  end


  private

  def parse_payment_order_data
    policy = user.enforce_policy_enabled? ? user.policies.non_default.first : user.policies.default.first
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
        scheduled_at: self.scheduled_at,
        api_initiated: false
    }
    bpr_attributes = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        beneficiary_type_id: 2,
        # policy_id: policy&.id,
        policy_id: self.policy.id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: false
    }
    bpr_attributes
  end

  def parse_payment_params
    # payment_params = []
    # self.inward_invoices.each do |invoice|
    #   po_id = invoice[:purchase_order_id]
    #   advance_amount = invoice[:advance_amount]
    #   # purchase_order = current_company.purchase_orders.find_by(po_number: po_number)
    #   purchase_order = user.company.purchase_orders.find_by(id: po_id)
    #   vendor = purchase_order.vendor
    #   bank_account = vendor.bank_accounts.where(default_account: true).first
    #   payment_params << {
    #       name: vendor.name,
    #       bank_account_number: bank_account.account_number,
    #       ifsc: bank_account.ifsc,
    #       requested_amount:self.payable_amounts[invoice.id],
    #       account_id: bank_account.id,
    #       invoice_id: invoice&.id,
    #       payment_purpose_id: PaymentPurpose.id_for(:invoice),
    #       parent_type: purchase_order&.class.name,
    #       parent_id: purchase_order&.id
    #   }
    # end

    payment_params = []
    self.inward_invoices.each do |invoice|
      bank_account = invoice.vendor.bank_accounts.where(default_account: true).first
      payment_params << {
          name: invoice.vendor.name,
          bank_account_number: bank_account.account_number,
          ifsc: bank_account.ifsc,
          account_id: bank_account.id,
          requested_amount: self.payable_amounts[invoice.id],
          payment_type_id: PaymentType.id_for(:credit),
          application: RequestStore.store[:current_app],
          receiving_user_type: invoice.bank_account&.account_owner&.class&.name,
          receiving_user_id: invoice.bank_account&.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: user.company.yes_bank_company_account&.class&.name,
          initiating_account_id: user.company.yes_bank_company_account&.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: invoice.bank_account&.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_mode: self.payment_mode,
          amount_attributes: {
              value: self.payable_amounts[invoice.id],
              currency_id: Currency.first.id
          },
          note: invoice.note,
          category_id: invoice.category_id,
          date: DateUtils.local_date,
          invoice_id: invoice.id,
          parent_type: invoice&.class.name,
          parent_id: invoice&.id
      }
    end

    payment_params
  end

end