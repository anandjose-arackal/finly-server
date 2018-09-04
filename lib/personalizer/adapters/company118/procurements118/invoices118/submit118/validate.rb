class Personalizer::Adapters::Company118::Procurements118::Invoices118::Submit118::Validate < Personalizer::Adapters::Base
  attr_accessor :invoice, :purchase_order, :procurement
  def init
    self.invoice = op_instance.invoice
    self.procurement = invoice.procurement
    self.purchase_order =  procurement&.purchase_order
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end
  end

  def process
    if invoice.net_amount.value > purchase_order.balance_amount.value
      add_message :error, 'Could not submit invoice. Invoice total amount is greater than purchase order amount'
    end
  end
end