class CreateTestInvoices < ActiveRecord::Migration[6.0]
  def change
    if Rails.env.development?
      create_table :test_invoices do |t|
        t.string :line_item_id, index: true, null: false
        t.string :invoice_id, index: true
        t.string :invoice_number, index: true
        t.string :created_by
        t.string :status
        t.string :submitted_at
        t.string :approved_at
        t.string :invoice_date
        t.string :due_date
        t.string :po_number
        t.string :discount_amount
        t.string :tax_type
        t.string :tax_amount
        t.string :tds_slab
        t.string :tds_rate
        t.string :tds_amount
        t.string :freight_amount
        t.string :net_amount
        t.string :paid_amount
        t.string :balance_payable
        t.string :policy_id
        t.string :policy_name
        t.string :vendor_id
        t.string :business_name
        t.string :trade_name
        t.string :vendor_location_name
        t.string :vendor_location_address
        t.string :billing_location_name
        t.string :billing_location_address
        t.string :shipping_location_name
        t.string :shipping_location_address
        t.string :item_code
        t.string :item_description
        t.string :item_category
        t.string :item_department
        t.string :item_cost_center
        t.string :item_hsn_sac
        t.string :item_tds_applicable
        t.string :item_unit_of_measurement
        t.string :item_quantity
        t.string :item_rate
        t.string :item_gross_amount
        t.string :item_discount
        t.string :item_discount_amount
        t.string :item_taxable_amount
        t.string :item_tax_rate
        t.string :item_tax_amount
        t.string :item_net_amount
        t.text :attachment_url
      end
    end
  end
end
