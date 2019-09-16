class AddColumnsToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :address_id, :integer
    add_column :general_invoices, :date, :date
    add_column :general_invoices, :due_date, :date
    add_column :general_invoices, :invoice_number, :text
    add_column :general_invoices, :tax_type_id, :integer
    add_column :general_invoices, :discount, :decimal, precision: 64, scale: 12
    add_column :general_invoices, :discount_type_id, :integer
    add_column :general_invoices, :gross_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :net_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :inclusive_of_taxes, :boolean
    add_column :general_invoices, :amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :tds, :decimal, precision: 64, scale: 12
    add_column :general_invoices, :tds_type_id, :integer
    add_column :general_invoices, :gst_type_id, :integer
    add_column :general_invoices, :payment_id, :integer
    add_column :general_invoices, :discount_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :tds_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :tax_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :tax, :decimal, precision: 64, scale: 12
    add_column :general_invoices, :category_id, :integer
    add_column :general_invoices, :original_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :advance_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :advance_type_id, :integer
    add_column :general_invoices, :advance, :decimal, precision: 20, scale: 10
    add_column :general_invoices, :freight_amount_id, :integer
    add_column :general_invoices, :freight_type_id, :integer
    add_column :general_invoices, :freight, :decimal, precision: 20, scale: 10
    add_column :general_invoices, :roundoff_amount, :decimal, precision: 20, scale: 10
    add_column :general_invoices, :balance_due_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :taxable_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :tds_slab_id, :integer
    add_column :general_invoices, :invoice_status_id, :integer
    add_column :general_invoices, :company_id, :integer
    add_column :general_invoices, :created_by_user_id, :integer
    add_column :general_invoices, :paid_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :receiving_account_id, :integer
    add_column :general_invoices, :receiving_account_type, :string
    add_column :general_invoices, :procurement_id, :integer
    add_column :general_invoices, :remaining_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :general_invoices, :invoice_type_id, :integer
    # add_column :general_invoices, :delivery_location_id, :integer
    add_column :general_invoices, :sub_department_id, :integer
    # add_column :general_invoices, :policy_id, :integer
    # add_column :general_invoices, :controlling_level_id, :integer
    # add_column :general_invoices, :controlling_user_id, :integer
    # add_column :general_invoices, :controlling_user_role_id, :integer
    # add_column :general_invoices, :controlling_for_user_id, :integer
    # add_column :general_invoices, :controlling_for_user_role_id, :integer
    # add_column :general_invoices, :billing_address, :text
    # add_column :general_invoices, :shipping_address, :text
    add_column :general_invoices, :is_template, :boolean, default: false
    add_column :general_invoices, :template_name, :string
    add_column :general_invoices, :is_deleted, :boolean, default: false
    add_column :general_invoices, :resource_template_id, :integer
    add_column :general_invoices, :invoice_id, :string, index: true
    add_column :general_invoices, :deleted_at, :datetime
    # add_column :general_invoices, :submitted_at, :datetime
    # add_column :general_invoices, :approved_at, :datetime
    # add_column :general_invoices, :po_adjusted_advance, :integer
    # add_column :general_invoices, :po_advance, :integer
    # add_column :general_invoices, :po_prev_adjusted_advance, :integer
    # add_column :general_invoices, :advance_amount_required, :boolean, default: false
    add_column :general_invoices, :gstin_location_id, :integer
    add_column :general_invoices, :transaction_service_period_from, :date
    add_column :general_invoices, :transaction_service_period_to, :date
    # add_column :general_invoices, :proforma_invoice_id, :integer
    # add_column :general_invoices, :proforma_advance, :integer
    # add_column :general_invoices, :total_proforma_advance, :decimal, precision: 20, scale: 2
    add_column :general_invoices, :cost_allocation_items, :boolean, default: false
    add_column :general_invoices, :narration, :text
    add_column :general_invoices, :po_number, :string
    add_column :general_invoices, :payment_agreement_id, :integer, index: true
    add_column :general_invoices, :bank_account_id, :integer
    add_column :general_invoices, :vendor_location_id, :integer
    add_column :general_invoices, :rejection_note, :text
    # add_column :general_invoices, :payment_agreement_escalation_id, :integer
    add_column :general_invoices, :invoice_frequency_id, :integer
    add_column :general_invoices, :billing_start_date, :datetime
    add_column :general_invoices, :billing_day_of_month, :integer
    add_column :general_invoices, :payment_agreement_upcoming_date, :date
    add_column :general_invoices, :is_payment_agreement_upcoming_invoice, :boolean
    add_column :general_invoices, :recurring_invoice_id, :integer
    add_column :general_invoices, :vendor_poc_id, :integer
    add_column :general_invoices, :vlpm_id, :integer
    add_column :general_invoices, :client_note, :text
    add_column :general_invoices, :start_date, :date
    add_column :general_invoices, :end_date, :date
    add_column :general_invoices, :lock_in_period, :integer
    add_column :general_invoices, :rent_free_period, :integer
    add_column :general_invoices, :tenancy_period, :integer
  end
end
