class AddInvoiceNumberConfigurationForCompanies < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_number_configs do |t|
      t.string :prefix, default: ""
      t.string :sequence_start
      t.references :company

      t.timestamps null: false
    end

    # Creating invoice number configuration models for all existing companies
    Company.all.each do |company|
      # company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:tax_invoice)}).save
      # company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:advance)}).save
      # company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:credit_note)}).save
      # company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save
      # company.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save
    end
  end
end