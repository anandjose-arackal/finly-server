class Procurements::PurchaseOrders::Templates::Destroy < Procurements::PurchaseOrders::Templates::Base
  attr_accessor :template

  def init
    result = Procurements::PurchaseOrders::Templates::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.purchase_order
  end

  def process
    unless self.template.destroy
      add_message :error, self.template.errors.full_messages
    end
  end

end