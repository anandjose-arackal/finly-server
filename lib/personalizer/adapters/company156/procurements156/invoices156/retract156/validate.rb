class Personalizer::Adapters::Company156::Procurements156::Invoices156::Retract156::Validate < Personalizer::Adapters::Base

  attr_accessor :inward_invoice

  def init
    self.inward_invoice = op_instance.invoice
  end

  def validate
    if self.inward_invoice&.get_level(:current)&.level_number > 2
      add_message :error, 'The invoice cannot be retracted in the current stage'
    end
  end

end