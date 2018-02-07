class AddInvoiceNumberConfigurationForCompanies < ActiveRecord::Migration
  def change
    create_table :invoice_number_configs do |t|
      t.string :prefix, default: ""
      t.string :sequence_start
      t.references :company

      t.timestamps null: false
    end

    # Creating invoice number configuration models for all existing companies
    Company.all.each do |company|
      company.build_invoice_number_config(sequence_start: "0000").save
    end
  end
end