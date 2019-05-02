class Procurements::Invoices::BulkApprove < Procurements::Invoices::Base
  attr_accessor :invoices

  def init
    invoice_ids = params[:ids] || params[:invoice_ids]

    unless invoice_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    # self.invoices = user.company.inward_invoices.with_id(invoice_ids)
    # self.invoices = Invoice.awaiting_action_items(user).with_id(invoice_ids)
    self.invoices = Procurements::Invoices::Index.(user, params).invoices.with_id(invoice_ids)
  end

  def validate
    if self.invoices.empty?
      add_message :error, 'No Invoices found'
    end

    accept_invoice = []
    self.invoices.each do |invoice|
      valid = (invoice.can_really_approve?) ? true : false

      if valid
        accept_invoice << invoice.id
      end
    end
 
    self.invoices = self.invoices.where(id: accept_invoice)

    if self.invoices.blank?
      add_message :error, "None of the invoices are in a state to be accepted."
      return
    end

  end

  def process
    Procurements::Invoices::BulkApproveProcessor.call_async(user.id, {invoice_ids: invoices.pluck(:id)})
    # Procurements::Invoices::BulkApproveProcessor.call(user.id, {invoice_ids: invoices.pluck(:id)})
  end

  def post_process
    add_message :success, "Invoices are being approved. You will be notified via mail once all are approved"
  end
end