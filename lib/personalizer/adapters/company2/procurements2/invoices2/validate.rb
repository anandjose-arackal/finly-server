class Personalizer::Adapters::Company2::Procurements2::Invoices2::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order
  def init
    self.purchase_order = op_instance.purchase_order
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    # if purchase_order.custom_fields.first&.value&.value
    #   unless purchase_order.all_items_shipped?
    #     add_message :error, 'Cannot add invoice till all the items are shipped'
    #   end
    # end
  end

end