class CreateGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :general_invoices do |t|
      t.integer :vendor_id
      t.integer :department_id
      t.integer :location_id
      t.integer :cost_center_id
      t.integer :payment_term_id
      t.boolean :auto_pay
      t.text :note
      t.integer :billing_type_id

      t.timestamps
    end
  end
end
