class Event::EOutwardInvoice::Base < Event::Base
  attr_accessor :outward_invoice

  def pre_validate
    if params[:outward_invoice_id].blank?
      add_message :error, 'Outward invoice not found'
      return
    end
  end

  def init
    id = params[:outward_invoice_id] || params[:id] || params[:invoice_id]
    self.outward_invoice = OutwardInvoice.find id
    unless outward_invoice
      add_message :error, 'Outward invoice not found'
      return
    end
  end
end
