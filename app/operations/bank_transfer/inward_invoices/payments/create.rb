# this operation will create a payment from an existing invoice
# which will be wrapped within a payment order and can be processed separately
class BankTransfer::InwardInvoices::Payments::Create < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :scheduled_at, :payment_mode, :policy_id,
                :description, :bank_payment_request

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    self.policy_id = params[:policy_id]
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
    end
  end

  def process

  end

  def post_process
    add_message :success, "Payment order created"
  end


  private

  def create_payment_request
    payment_params = [{
        payment_type_id: PaymentType.id_for(:credit),
        application: RequestStore.store[:current_app],
        receiving_user_type: self.inward_invoice.bank_account&.account_owner&.class&.name,
        receiving_user_id: self.inward_invoice.bank_account&.account_owner_id,
        initiating_user_type: "User",
        initiating_user_id: user.id,
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        initiating_account_id: user.company.yes_bank_company_account&.id,
        receiving_account_type: "BankAccount",
        receiving_account_id: self.inward_invoice.bank_account&.id,
        payment_status_id: PaymentStatus.id_for(:pending_approval),
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        payment_mode: self.payment_mode, # todo - default is NEFT for now, can be changed to something else later
        amount_attributes: {
            value: self.inward_invoice.balance_due&.value,
            currency_id: Currency.first.id
        },
        note: self.inward_invoice.note,
        category_id: self.inward_invoice.category_id,
        date: DateUtils.local_date
    }]
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.inward_invoice.balance_due&.value,
            current_id: 1
        },
        payment_mode: "NEFT",
        initiating_account_type: user.company.yes_bank_company_account&.class&.name,
        receiving_account_type: "BankAccount",
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
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
            value: self.inward_invoice.balance_due&.value,
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