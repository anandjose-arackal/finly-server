class MoveExistingInvoiceNumberConfigsToNewStructure < ActiveRecord::Migration[4.2]
  def change
    InvoiceNumberConfig.update_all(purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:tax_invoice))
    Company.all.each do |company|
      company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:advance)}).save if company.invoice_number_configs.with_config_type_id(InvoiceNumberConfigType.id_for(:advance)).empty?
      company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:credit_note)}).save if company.invoice_number_configs.with_config_type_id(InvoiceNumberConfigType.id_for(:credit_note)).empty?
      company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save if company.invoice_number_configs.with_config_type_id(InvoiceNumberConfigType.id_for(:debit_note)).empty?
      company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save if company.invoice_number_configs.with_purpose_id(Purpose.id_for(:vendor_payments)).with_config_type_id(InvoiceNumberConfigType.id_for(:debit_note)).empty?
    end
  end
end
