class Personalizer::Adapters::Company156::Procurements156::Invoices156::Update156::PostProcess < Personalizer::Adapters::Base

  attr_accessor :inward_invoice

  def init
    self.inward_invoice = op_instance.inward_invoice
  end

  def process
    if self.inward_invoice.narration.blank?
      # Narration will be a concatenation of
      field_configuration = self.inward_invoice&.created_by&.company&.field_configurations&.where(field_name: "Nature of Expense")&.first
      nature_of_expense = self.inward_invoice.custom_fields.with_field_configuration_ids(field_configuration&.id)&.first
      invoice_number = self.inward_invoice.invoice_number
      date = self.inward_invoice&.date&.strftime("%Y-%m-%d")
      location = self.inward_invoice&.location&.name
      department = self.inward_invoice&.department&.name
      unique_reference = self.inward_invoice&.invoice_id
      narration = "#{nature_of_expense&.string_value} | #{invoice_number} | #{date} | #{location} | #{department} | #{unique_reference}"

      self.inward_invoice.update(narration: narration)
    end
    inward_invoice.custom_fields.each do |cf|
      next if cf.field_key != 'estimated_payment_date'
      if cf.value&.value.nil?
        estimated_payment_date =  FieldText.create(value: inward_invoice.due_date&.strftime("%d-%b-%Y"))
        cf.update_columns(value_id: estimated_payment_date.id,value_type:'FieldText')
      end
    end
  end

end