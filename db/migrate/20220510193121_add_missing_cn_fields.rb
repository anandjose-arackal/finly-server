class AddMissingCnFields < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_note_items, :item_number, :string
    add_column :credit_note_items, :original_tax_percentage, :decimal, precision: 20, scale: 10
    add_column :credit_note_items, :tax_percentage, :decimal, precision: 20, scale: 10
    add_column :credit_note_items, :item_total_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :cn_tds_rate, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :net_adjusted_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :conversion_rate, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :conversion_date, :datetime

    add_column :credit_notes, :reporting_cn_gross_receivable_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :reporting_cn_tax_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :reporting_cn_net_receivable_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :reporting_cn_previously_adjusted_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :reporting_net_adjusted_amount, :decimal, precision: 20, scale: 10
    add_column :credit_notes, :gstin_location_id, :integer
    add_column :credit_notes, :vendor_country_id, :integer
    add_column :credit_notes, :vendor_gstin, :string
    add_column :credit_notes, :rejection_note, :text
  end
end
