class CreateGstFilingApiCallLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :gst_filing_api_call_logs do |t|
      t.string :gstin, null: false
      t.string :financial_year, null: false
      t.boolean :success
      t.text :response_json
      t.string :request_url, null: false
      t.integer :company_id, index: true, null: false, foreign_key: true, references: 'companies'
      t.integer :vendor_id
      t.string :invoice_id

      t.timestamps
    end
  end
end
