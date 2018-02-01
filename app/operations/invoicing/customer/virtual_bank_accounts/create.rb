# this operation creates a particular virtual bank account for a particular customer
class Invoicing::Customer::VirtualBankAccounts::Create < Invoicing::Customer::Base

  attr_accessor :customer, :invoice, :virtual_account

  def init
    id = params[:id] || params[:customer_id]
    self.customer = user.company.customers.find_by(id: id)
    # if the virtual bank account is being created from within an invoice, set it as parent
    invoice_id = params[:invoice_id]
    self.invoice = self.customer.virtual_bank_accounts.find_by(id: invoice_id)
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
      return
    end

    if self.invoice.blank? && params[:invoice_id].present?
      add_message :error, "Invoice not found"
    end
  end

  def process
    purpose_id = self.invoice.present? ? VirtualAccountPurpose.id_for(:invoice) : nil
    op = Invoicing::VirtualBankAccount::Create.(user, {
        purpose_id: purpose_id,
        parent: self.invoice,
        customer: self.customer
    })
    if op.success?
      self.virtual_account = op.virtual_bank_account
    else
      add_message :error, op.messages[:error]
    end
  end

  def post_process
    add_message :error, "Virtual account created"
  end
end