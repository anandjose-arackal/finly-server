class AddNewDetailsToVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :vendor_country, :string

    add_column :yes_bank_vendors, :ldc_upper_limit_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :yes_bank_vendors, :ldc_effective_start_date, :date
    add_column :yes_bank_vendors, :ldc_effective_end_date, :date

    add_column :yes_bank_vendors, :tds_effective_start_date, :date
    add_column :yes_bank_vendors, :tds_effective_end_date, :date


    add_column :gstin_locations, :gst_status, :string
    add_column :gstin_locations, :gst_expiry_date, :date
  end
end
