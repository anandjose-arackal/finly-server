# this operation adds an invoice to a payment order and picks up details
# for the payment from there
class BankTransfer::PaymentRequest::InwardInvoice::Add < BankTransfer::PaymentRequest::Base

  attr_accessor :inward_invoices, :payments, :bank_payment_request, :payable_amounts,
                :invoices_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end

    if params[:invoices].blank?
      add_message :error, "Invoices params not present"
    end
  end

  def init
    self.payable_amounts = {}
    ids = []
    self.invoices_params = params[:invoices]
    self.invoices_params.each do |param|
      ids << param[:invoice_id]
      self.payable_amounts[param[:invoice_id]&.to_i] = param[:payable_amount].to_f
    end
    self.inward_invoices = user.company.inward_invoices.with_id(ids)
    bank_payment_request_id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: bank_payment_request_id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment ticket not found"
      return
    end

    if self.inward_invoices.empty?
      add_message :error, "Nothing to add"
      return
    end

    # todo - add conditions to select how much of the invoice will be paid int his payment
    self.payable_amounts.each do |invoice_id, payable_amount|
      invoice = self.inward_invoices.find_by(id: invoice_id)
      if invoice.remaining_amount.blank?
        next
      end
      if payable_amount > invoice.remaining_amount&.value.to_f
        add_message :error, "You cannot pay more than the remaining amount in an invoice"
      end
    end
  end

  def pre_process
    initialize_payment_objects
  end

  def process
    payment_order = self.bank_payment_request.payment_order
    self.payments.each do |payment|
      payment.update(payment_order_id: payment_order.id)
      debugger
    end
  end

  def post_process
    add_message :success, "Successfully added invoices to the Order"
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
end