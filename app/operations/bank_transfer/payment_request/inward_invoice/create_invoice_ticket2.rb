# this operation will create a payment from an existing invoice
# which will be wrapped within a payment order and can be processed separately
class BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket2 < BankTransfer::InwardInvoices::Base

  def personalizer
    {
        post_process: {
            after: Personalizer::Process.new([:bank_transfer, :payments, :create], :post_process, self)
        }
    }
  end

  attr_accessor :inward_invoice, :scheduled_at, :payment_mode, :policy_id,
                :description, :bank_payment_request, :payable_amount,
                :payment_request_params, :policy, :bank_payment_request_params, :payable_amounts, :requested_amount, :inward_invoices,
                :payments, :invoices_params

  class BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket2::BankPaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

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
      if params[:invoices_attributes].blank?
        add_message :error, 'No Invoices sent for processing.'
        return
      end
  end

  def init
    # params[:policy_id] = 4
    # # params[:purchase_order_id] = 1733
    # params[:scheduled_at] = "2019-02-28"
    # params[:payment_mode] = 'neft'
    # params[:invoices] = [{invoice_id: 40343, payable_amount: '1' }]
    self.payable_amounts = {}
    self.requested_amount = 0
    ids = []
    self.invoices_params = params[:invoices_attributes]
    self.invoices_params.each do |param|
      ids << param[:invoice_id]
      self.payable_amounts[param[:invoice_id]&.to_i] = param[:payable_amount].to_f
    end
    self.inward_invoices = user.company.inward_invoices.with_id(ids)
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    policy_id = params[:policy_id]
    self.policy = current_company.policies.find_by(id: policy_id)

    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    # self.inward_invoice = user.company.inward_invoices.find_by(id: id)
    # self.scheduled_at = params[:scheduled_at]
    # self.payment_mode = params[:payment_mode]
    # self.policy_id = params[:policy_id]
    # self.payable_amount = params[:payable_amount]

  end

  def validate
    if self.inward_invoices.empty?
      add_message :error, "Nothing to add"
      return
    end

    # todo - add conditions to select how much of the invoice will be paid in this payment
    self.payable_amounts.each do |invoice_id, payable_amount|
      # binding.pry
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
    self.payment_request_params = bank_payment_request_params
    self.bank_payment_request = user.bank_payment_requests.build(self.payment_request_params)
    if self.bank_payment_request.save
      # any changes to be made here? #todo
      initialize_payment_objects
      payment_order = self.bank_payment_request.payment_order
      self.payments.each do |payment|
        payment.update(payment_order_id: payment_order.id)
      end
    else
      add_message :error, self.bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment order created"

    # Set status to unpaid if done via a procurement
    # if inward_invoice.procurement_id.present?
    #   inward_invoice.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
    # end
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::InwardInvoice::CreateInvoiceTicket2::BankPaymentRequestPresenter.new(user, params, messages)
  end


  private

  def initialize_payment_objects
    payment_params = []
    self.inward_invoices.each do |invoice|
      payment_params << {
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
          payment_mode: self.bank_payment_request.payment_mode,
          amount_attributes: {
              value: self.payable_amounts[invoice.id],
              currency_id: Currency.first.id
          },
          note: invoice.note,
          category_id: invoice.category_id,
          date: DateUtils.local_date,
          invoice_id: invoice.id
      }
    end
    self.payments = self.bank_payment_request.payment_order.payments.build(payment_params)
  end

  def bank_payment_request_params
    # payment_params = [{
    #     payment_type_id: PaymentType.id_for(:credit),
    #     application: RequestStore.store[:current_app],
    #     receiving_user_type: self.inward_invoice.bank_account&.account_owner&.class&.name,
    #     receiving_user_id: self.inward_invoice.bank_account&.account_owner_id,
    #     initiating_user_type: "User",
    #     initiating_user_id: user.id,
    #     initiating_account_type: user.company.yes_bank_company_account&.class&.name,
    #     initiating_account_id: user.company.yes_bank_company_account&.id,
    #     receiving_account_type: "BankAccount",
    #     receiving_account_id: self.inward_invoice.bank_account&.id,
    #     payment_status_id: PaymentStatus.id_for(:pending_approval),
    #     payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
    #     payment_mode: self.payment_mode, # todo - default is NEFT for now, can be changed to something else later
    #     amount_attributes: {
    #         value: self.requested_amount,
    #         currency_id: Currency.first.id
    #     },
    #     note: self.inward_invoice.note,
    #     category_id: self.inward_invoice.category_id,
    #     date: DateUtils.local_date,
    #     invoice_id: self.inward_invoice.id
    # }]
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        payment_mode: "NEFT",
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        receiving_account_type: "BankAccount",
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        application: RequestStore.store[:current_app],
        currency_id: 1,
        scheduled_at: self.scheduled_at
    }
    bank_payment_request_params = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:open),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.requested_amount,
            currency_id: 1
        },
        description: self.description,
        beneficiary_type_id: 2, # this is because an invoice will always come from a vendor
        policy_id: self.policy_id,
        payment_order_attributes: payment_order_params
    }
    return bank_payment_request_params
  end

end