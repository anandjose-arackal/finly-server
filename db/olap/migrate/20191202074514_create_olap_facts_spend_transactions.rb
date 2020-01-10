class CreateOlapFactsSpendTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_facts_spend_transactions do |t|
      t.olap_references
      t.string :document_type, index: true
      t.integer :document_id, index: true

      t.string :parent_document_type, index: true
      t.integer :parent_document_id, index: true

      # Employee Expenses
      t.boolean :is_reimbursable, index: true
      t.integer :reimbursed_on_id

      # Header - General
      t.string :status, index: true
      t.string :description, index: true
      t.text :detailed_description
      t.integer :parent_cost_center_id
      t.integer :cost_center_id
      t.integer :parent_location_id
      t.integer :location_id
      t.integer :parent_department_id
      t.integer :department_id
      t.integer :parent_category_id
      t.integer :category_id
      t.integer :policy_id
      t.integer :owner_id
      t.integer :service_period_start_id
      t.integer :service_period_end_id
      t.integer :date_id
      t.integer :transaction_created_at_id
      t.integer :transaction_submitted_at_id
      t.integer :transaction_approved_at_id
      t.integer :transaction_rejected_at_id, index: true
      t.integer :transaction_rejection_count, index: true
      t.boolean :has_violation, index: true
      t.string :violation_description, index: true

      # Payee
      t.boolean :is_employee_expense, index: true
      t.boolean :is_vendor_payment, index: true
      t.integer :vendor_id
      t.integer :vendor_location_id
      t.string :vendor_name, index: true
      t.integer :shipping_location_id
      t.integer :billing_location_id
      t.boolean :is_gst_registered, index: true
      t.boolean :is_msme_registered, index: true
      t.boolean :is_composite_vendor, index: true
      t.integer :vendor_confirmed_at_id
      t.integer :days_for_confirmation, index: true
      t.integer :payment_mode, index: true

      # Item
      t.decimal :quantity, index: true
      t.integer :estimated_delivery_date_id
      t.integer :delivery_completed_on_id
      t.boolean :is_delivered_on_time, index: true
      t.boolean :has_on_time_delivery, index: true
      t.boolean :has_late_delivery, index: true
      t.integer :delivery_delayed_days, index: true
      t.decimal :quantity_delivered_on_time, index: true
      t.decimal :quantity_delivered_on_time_percentage, index: true
      t.decimal :quantity_delivered_late, index: true
      t.decimal :quantity_delivered_late_percentage, index: true
      t.boolean :is_exceeding_budget, index: true
      t.string :item_type, index: true # Goods/Service
      t.integer :item_id
      t.string :asset_type # Capex/Opex

      # Spend
      t.integer :amount_id
      t.integer :basic_amount_id
      t.integer :tax_amount_id
      t.integer :tds_amount_id
      t.string :tax_type, index: true
      t.decimal :tax_percentage, index: true
      t.integer :cgst_amount_id
      t.integer :sgst_amount_id
      t.integer :igst_amount_id
      t.decimal :cgst_percentage, index: true
      t.decimal :sgst_percentage, index: true
      t.decimal :igst_percentage, index: true
      t.integer :advance_amount_requested_id
      t.integer :advance_amount_paid_id
      t.decimal :advance_percentage, index: true
      t.integer :credit_days, index: true
      t.decimal :reimbursement_amount_id

      t.timestamps index: true
    end
  end
end
