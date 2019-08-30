class CreateRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :rental_invoices do |t|
      t.integer :address_id
      t.date :date
      t.date :due_date
      t.text :invoice_number
      t.integer :tax_type_id
      t.decimal :discount
      t.integer :discount_type_id
      t.integer :gross_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :net_amount_id, references: "Amount", foreign_key: true, index: true
      t.boolean :inclusive_of_taxes
      t.integer :amount_id, references: "Amount", foreign_key: true, index: true
      t.decimal :tds
      t.integer :tds_type_id
      t.integer :gst_type_id
      t.integer :payment_id
      t.integer :discount_amount_id
      t.integer :tds_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.decimal :tax
      t.integer :category_id
      t.integer :original_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :advance_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :advance_type_id, references: "Amount", foreign_key: true, index: true
      t.decimal :advance
      t.integer :freight_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :freight_type_id
      t.decimal :freight
      t.decimal :roundoff_amount
      t.integer :balance_due_id, references: "Amount", foreign_key: true, index: true
      t.integer :taxable_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :tds_slab_id
      t.integer :invoice_status_id
      t.integer :company_id
      t.integer :created_by_user_id
      t.integer :paid_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :receiving_account_id
      t.string :receiving_account_type
      t.integer :procurement_id
      t.integer :remaining_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :invoice_type_id
      t.integer :delivery_location_id
      t.integer :sub_department_id
      t.integer :policy_id
      # t.integer :controlling_level_id
      # t.integer :controlling_user_id
      # t.integer :controlling_user_role_id
      # t.integer :controlling_for_user_id
      # t.integer :controlling_for_user_role_id
      # t.text :billing_address
      # t.text :shipping_address
      t.boolean :is_template
      t.string :template_name
      t.boolean :is_deleted
      t.integer :resource_template_id
      t.string :invoice_id
      t.datetime :deleted_at
      # t.datetime :submitted_at
      # t.datetime :approved_at
      # t.integer :po_adjusted_advance
      # t.integer :po_advance
      # t.integer :po_prev_adjusted_advance
      # t.boolean :advance_amount_required
      t.integer :gstin_location_id
      t.date :transaction_service_period_from
      t.date :transaction_service_period_to
      # t.integer :proforma_invoice_id
      # t.integer :proforma_advance
      # t.decimal :total_proforma_advance
      t.boolean :cost_allocation_items
      t.text :narration
      t.string :po_number
      t.integer :payment_agreement_id
      t.integer :bank_account_id
      t.integer :vendor_location_id
      t.text :rejection_note
      t.integer :payment_agreement_escalation_id
      t.integer :invoice_frequency_id
      t.datetime :billing_start_date
      t.integer :billing_day_of_month
      t.date :payment_agreement_upcoming_date
      t.boolean :is_payment_agreement_upcoming_invoice
      t.integer :recurring_invoice_id
      t.integer :vendor_poc_id
      t.integer :vlpm_id
      t.text :client_note
      t.date :start_date
      t.date :end_date
      t.integer :lock_in_period
      t.integer :rent_free_period
      t.integer :tenancy_period
      t.integer :vendor_id
      t.integer :department_id
      t.integer :location_id
      t.integer :cost_center_id
      t.integer :payment_term_id
      t.text :note
      t.integer :billing_type_id

      t.timestamps
    end
  end
end
