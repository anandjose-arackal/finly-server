class CreateGstFilingRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :gst_filing_records do |t|
      t.date :date_of_filing
      t.string :mode_of_filing
      t.string :return_period, null: false
      t.date :return_period_date, null: false
      t.string :status, null: false
      t.string :valid
      t.string :return_type, null: false
      t.string :gstin, null: false
      t.string :financial_year, null: false
      t.string :arn

      t.integer :yes_bank_vendor_id, index: true, null: true, foreign_key: true, references: 'yes_bank_vendors'
      t.integer :gstin_location_id, index: true, null: true, foreign_key: true, references: 'gstin_locations'
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'

      t.timestamps
    end
    add_index :gst_filing_records, [:company_id, :gstin, :return_period, :return_type], unique: true, name: 'index_gst_company_gstin_ret_prd'

  end
end
