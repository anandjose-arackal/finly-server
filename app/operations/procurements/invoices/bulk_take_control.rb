class Procurements::Invoices::BulkTakeControl < Procurements::Invoices::Base
  attr_accessor :invoices

  def init
    invoice_ids = params[:ids] || params[:invoice_ids]

    unless invoice_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.invoices = Procurements::Invoices::Index.(user, params).invoices.with_id(invoice_ids)
  end

  def validate
    if self.invoices.empty?
      add_message :error, 'No Invoices found'
    end
  end

  def process
    Procurements::Invoices::BulkTakeControlProcessor.call_async(user.id, {invoice_ids: invoices.pluck(:id)})
  end

  def post_process
    add_message :success, "Taking control of multiple invoices (#{self.invoices.length}). You will be notified via mail once all are done."
  end
end