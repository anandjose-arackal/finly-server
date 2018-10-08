class Procurements::Invoices::Templates::Destroy < Procurements::Invoices::Templates::Base
  attr_accessor :template

  def init
    result = Procurements::Invoices::Templates::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.invoice
  end

  def process
    unless self.template.destroy
      add_message :error, self.template.errors.full_messages
    end
  end

end