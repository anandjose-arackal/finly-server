class Personalizer::Adapters::Company2::Procurements2::Invoices2::Approve2::PostProcess < Personalizer::Adapters::Base

  attr_accessor :inward_invoice

  def init
    self.inward_invoice = op_instance.invoice
  end

  def process
    if inward_invoice.present? && inward_invoice.due_date.present?
      #check the last approved level number 2
      if inward_invoice.get_level(:prev).level_number == 2
        next_due_date = TransferTimingUtils.add_business_days(inward_invoice.due_date, 5)
        inward_invoice.update_columns(due_date: next_due_date)
      end
    end
  end

end