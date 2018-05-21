# this operation will create a payment from an existing invoice
# which will be wrapped within a payment order and can be processed separately
class BankTransfer::InwardInvoice::Payments::Create < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice

  def init
    id = params[:id] || params[:invoice_id]
    self.inward_invoice = user.company.inward_invoices.find_by(id: id)
  end


end