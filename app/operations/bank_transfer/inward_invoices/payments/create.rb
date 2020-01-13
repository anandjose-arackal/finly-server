# this operation will create a payment from an existing invoice
# which will be wrapped within a payment order and can be processed separately
class BankTransfer::InwardInvoices::Payments::Create < BankTransfer::InwardInvoices::Base

  def personalizer
    {
        post_process: {
            after: Personalizer::Process.new([:bank_transfer, :payments, :create], :post_process, self)
        }
    }
  end

  attr_accessor :inward_invoice, :scheduled_at, :payment_mode, :policy_id,
                :description, :bank_payment_request, :payable_amount,
                :payment_request_params, :policy

  class BankTransfer::InwardInvoices::Payments::Create::BankPaymentRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
    end

  end

  def init
    id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
    self.scheduled_at = params[:scheduled_at]
    self.payment_mode = params[:payment_mode]
    self.policy_id = params[:policy_id]
    self.payable_amount = params[:payable_amount]
    self.description = params[:description]

    result = Policy::VendorPayments::Index.(user, params)
    unless result.success?
      add_message :error, messages[:error]
      return
    end
    self.policy = result.policies.where id: self.policy_id
  end

  def validate
    if self.inward_invoice.blank?
      add_message :error, "Invoice not found"
    end

    if self.payable_amount.blank?
      add_message :error, "You need to enter a payable amount to create an order"
      return
    end

    unless InwardInvoiceStatus.ids_for(:approved, :auto_approved, :unpaid, :partially_paid).include?(inward_invoice.invoice_status_id)
      add_message :error, "You cannot credit this invoice as it already has a unprocessed payment associated with it"
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

    remaining_amount = (self.inward_invoice.balance_due&.value.to_f - self.inward_invoice.payments.successful.joins(:amount).sum(:value))

    if self.inward_invoice.vendor.blank?
      add_message :error, "This invoice does not have a vendor associated with it. Please add them before creating a payment ticket for it."
      return
    end
    if self.inward_invoice.bank_account.blank?
      add_message :error, "This invoice does not have a bank account selected for the chosen vendor, #{self.inward_invoice.vendor&.business_name || self.inward_invoice.vendor&.name}"
      return
    end

    if self.inward_invoice.bank_account&.disabled
        add_message :error, "This invoice has a bank account which is disabled. Payment can only be processed to active bank accounts."
        return
      end

    if self.payable_amount.to_f > remaining_amount.to_f
      add_message :error, "You cannot pay more than the remaining amount in an invoice. Maximum payable - #{self.inward_invoice.balance_due&.currency&.symbol}#{remaining_amount.to_f}"
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

    else
      add_message :error, self.bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment order created"

    # Set status to unpaid if done via a procurement
    if inward_invoice.procurement_id.present?
      inward_invoice.update(invoice_status_id: InwardInvoiceStatus.id_for(:initiated))
    end
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::InwardInvoices::Payments::Create::BankPaymentRequestPresenter.new(user, params, messages)
  end


  private

  def bank_payment_request_params
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
            value: self.payable_amount,
            currency_id: Currency.first.id
        },
        note: self.inward_invoice.narration,
        category_id: self.inward_invoice.category_id,
        department_id: self.inward_invoice.department_id,
        cost_center_id: self.inward_invoice.cost_center_id,
        date: DateUtils.local_date,
        invoice_id: self.inward_invoice.id,
        parent_type: self.inward_invoice.class.name,
        parent_id: self.inward_invoice.id
    }]
    payment_order_params = {
        initiating_user: user,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.payable_amount,
            currency_id: 1
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
            value: self.payable_amount,
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