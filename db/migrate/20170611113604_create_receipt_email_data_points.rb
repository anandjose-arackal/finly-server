class CreateReceiptEmailDataPoints < ActiveRecord::Migration
  def change
    create_table :receipt_email_data_points do |t|
      t.text :amount_xpath, null: false
      t.string :amount_xpath_regex, null: false
      t.text :amount_css_selector, null: false
      t.string :amount_css_selector_regex, null: false
      t.integer :amount_mode_id, references: 'ReceiptEmailDataPointMode', index: true, foreign_key: true, null: false
      t.references :receipt_email_template, index: true, foreign_key: true, null: false
      t.decimal :priority, null: false, default: 0

      t.timestamps null: false
    end
  end
end
