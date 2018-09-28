class Personalizer::Adapters::Company118::Procurements118::Invoices118::Submit118::Validate < Personalizer::Adapters::Base
  attr_accessor :invoice, :purchase_order, :procurement
  def init
    self.invoice = op_instance.invoice
    self.procurement = invoice.procurement
    self.purchase_order =  procurement&.purchase_order
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end
  end

  def process
    if self.purchase_order.present?
      purchase_order_base_amount = 0
      invoice_base_amount = 0

      purchase_order.items.each do |item|
        rate = item.rate
        quantity = item.quantity
        amount = rate * quantity
        purchase_order_base_amount += amount
      end

      invoice.invoice_items.each do |item|
        rate = item.rate
        quantity = item.quantity
        amount = rate * quantity
        invoice_base_amount += amount
      end

      if invoice_base_amount > purchase_order_base_amount
        add_message :error, 'Could not submit invoice. Invoice base amount is greater than purchase order base amount'
      end
      #todo add new logic based on base amount
      # if invoice.net_amount.value > purchase_order.balance_amount.value
      #   add_message :error, 'Could not submit invoice. Invoice total amount is greater than purchase order amount'
      # end
    end
  end
end