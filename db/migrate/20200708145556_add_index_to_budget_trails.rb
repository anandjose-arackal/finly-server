class AddIndexToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    add_index :budget_trails, :category_id
    add_index :budget_trails, :cost_center_id
    add_index :budget_trails, :location_id
    add_index :budget_trails, :vendor_id
    add_index :budget_trails, :amount_id
    add_index :budget_trails, :user_id
    add_index :budget_trails, :department_id
    add_index :budget_trails, :entity_date
    add_index :budget_trails, :sub_department_id
    add_index :budget_trails, :procurement_id
    add_index :budget_trails, :deleted_at
    add_index :budget_trails, :payment_processing_amount_before_tax_value, name: :idx_budget_trails_on_pmt_processing_amt_b4_tax_value
    add_index :budget_trails, :payment_processing_amount_after_tax_value, name: :idx_budget_trails_on_pmt_processing_amt_aftr_tax_value
    add_index :budget_trails, :tds_value
    add_index :budget_trails, :billed
    add_index :budget_trails, :entity_status_id
    add_index :budget_trails, :reimbursable
    add_index :budget_trails, :amount_before_tax_id
    add_index :budget_trails, :amount_after_tax_id
    add_index :budget_trails, :entity_created_at
    add_index :budget_trails, :entity_submitted_at
    add_index :budget_trails, :purchase_order_id
    add_index :budget_trails, :invoice_id
    add_index :budget_trails, :payment_purpose_id
    add_index :budget_trails, :po_trail_item_id
    add_index :budget_trails, :billed_amount_before_tax_value
    add_index :budget_trails, :billed_amount_after_tax_value
    add_index :budget_trails, :remaining_amount_before_tax_value
    add_index :budget_trails, :remaining_amount_after_tax_value
    add_index :budget_trails, :effective_paid_amount_before_tax_value
    add_index :budget_trails, :paid_amount_after_tax_value
    add_index :budget_trails, :billed_quantity rescue nil
    add_index :budget_trails, :billed_rate
    add_index :budget_trails, :remaining_quantity
    add_index :budget_trails, :revised
    add_index :budget_trails, :payment_confirmed
    add_index :budget_trails, :tax_amount_value
    add_index :budget_trails, :net_paid_amount_before_tax_value
    add_index :budget_trails, :rcm_tax_value
    add_index :budget_trails, :paid_tds_value
    add_index :budget_trails, :processing_tds_value
    add_index :budget_trails, :cn_adjusted_amount_before_tax_value
    add_index :budget_trails, :cn_adjusted_amount_after_tax_value
    add_index :budget_trails, :credit_note_tax_amount_value
    add_index :budget_trails, :date
  end
end
