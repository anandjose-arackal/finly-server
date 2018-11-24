class Procurements::Invoices::BulkApproveProcessor < BackgroundOperation
  attr_accessor :invoice_ids, :result

  def init
    self.invoice_ids = params[:invoice_ids]
    self.result = {
        success: [],
        error: []
    }
  end

  def validate
    if self.invoice_ids.blank?
      return
    end
  end

  def process
    invoice_ids.each do |id|
      data_success = {}
      data_error = {}
      op = Procurements::Invoices::Approve.(user, {invoice_id: id})
      invoice = Invoice.find_by id: id
      unless op.success?
        data_error[:messages] = op.messages[:error]
        data_error[:invoice_id] = invoice&.invoice_id
        data_error[:invoice_number] = invoice&.invoice_number
        data_error[:sub_department] = invoice&.sub_department&.name
        data_error[:department] = invoice&.department&.name
        data_error[:user] = invoice&.created_by&.name
        data_error[:amount] = invoice&.net_amount&.value
        self.result[:error].push(data_error)
      else
        data_success[:invoice_id] = invoice&.invoice_id
        data_success[:invoice_number] = invoice&.invoice_number
        data_success[:sub_department] = invoice&.sub_department&.name
        data_success[:department] = invoice&.department&.name
        data_success[:user] = invoice&.created_by&.name
        data_success[:amount] = invoice&.net_amount&.value
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    op = Event::EInvoice::BulkApprove.(user, result: result)
  end
end