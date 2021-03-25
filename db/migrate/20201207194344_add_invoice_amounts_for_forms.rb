class AddInvoiceAmountsForForms < ActiveRecord::Migration[6.0]
  def change
    # Remove Fields Added to Invoice & Line Items in AddAmountFieldsToInvoices added by Vivek
    # Fields are replaced with below set of fields

    if ActiveRecord::Base.connection.column_exists?(:invoices, :gross_amount)
      remove_column :invoices, :gross_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :discount_amount)
      remove_column :invoices, :discount_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :freight_amount)
      remove_column :invoices, :freight_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :taxable_amount)
      remove_column :invoices, :taxable_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :tax_amount)
      remove_column :invoices, :tax_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :tds_amount)
      remove_column :invoices, :tds_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :net_amount)
      remove_column :invoices, :net_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :po_advance_amount)
      remove_column :invoices, :po_advance_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :advance_paid_amount)
      remove_column :invoices, :advance_paid_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :total_paid_amount)
      remove_column :invoices, :total_paid_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :balance_due_amount)
      remove_column :invoices, :balance_due_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :currency_code)
      remove_column :invoices, :currency_code, if_exists: true
    end


    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :gross_amount)
      remove_column :invoice_line_items, :gross_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :discount_amount)
      remove_column :invoice_line_items, :discount_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :taxable_amount)
      remove_column :invoice_line_items, :taxable_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :tax_amount)
      remove_column :invoice_line_items, :tax_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :net_amount)
      remove_column :invoice_line_items, :net_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :currency_code)
      remove_column :invoice_line_items, :currency_code, if_exists: true
    end


    if ActiveRecord::Base.connection.column_exists?(:invoices, :payment_outside_finly_amount)
      remove_column :invoices, :payment_outside_finly_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :sub_total_amount)
      remove_column :invoices, :sub_total_amount, if_exists: true
    end

    if ActiveRecord::Base.connection.column_exists?(:invoices, :total_amount)
      remove_column :invoices, :total_amount, if_exists: true
    end


    # The following field additions are already taken care in other migrations [AddFormDetailsToInvoices, AddConvertedAmountsToInvoices]
    # When the initial deployment was done for vendors, adding the following attributes to production database was taking way too much time
    #   and the deployment was cancelled and the migration file was commented and redeployed; this only added a few fields to production database
    # The fields are added again with conditions so as to maintain integrity in all environments

    unless ActiveRecord::Base.connection.column_exists?(:invoices, :reporting_currency)
      add_column :invoices, :reporting_currency, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :conversion_date)
      add_column :invoices, :conversion_date, :date, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :conversion_rate)
      add_column :invoices, :conversion_rate, :decimal, :precision => 10, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :retrieve_conversion_rate)
      add_column :invoices, :retrieve_conversion_rate, :boolean, default: true, if_not_exists: true
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_sequence_id)
      add_column :invoices, :vendor_sequence_id, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_trade_name)
      add_column :invoices, :vendor_trade_name, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_gstin)
      add_column :invoices, :vendor_gstin, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_pan)
      add_column :invoices, :vendor_pan, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_bank_account_number)
      add_column :invoices, :vendor_bank_account_number, :string, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :vendor_bank_account_ifsc)
      add_column :invoices, :vendor_bank_account_ifsc, :string, if_not_exists: true
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_gross_amount)
      add_column :invoices, :invoice_gross_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_discount_amount)
      add_column :invoices, :invoice_discount_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_tax_amount)
      add_column :invoices, :invoice_tax_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_tds_amount)
      add_column :invoices, :invoice_tds_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_freight_amount)
      add_column :invoices, :invoice_freight_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_paid_outside_amount)
      add_column :invoices, :invoice_paid_outside_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_sub_total_amount)
      add_column :invoices, :invoice_sub_total_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_total_amount)
      add_column :invoices, :invoice_total_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_taxable_amount)
      add_column :invoices, :invoice_taxable_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_freight_amount)
      add_column :invoices, :invoice_freight_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_roundoff_amount)
      add_column :invoices, :invoice_roundoff_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_balance_due)
      add_column :invoices, :invoice_balance_due, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoices, :base_currency)
      add_column :invoices, :base_currency, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_gross_amount)
      add_column :invoice_line_items, :item_gross_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_discount_amount)
      add_column :invoice_line_items, :item_discount_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_taxable_amount)
      add_column :invoice_line_items, :item_taxable_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_tax_amount)
      add_column :invoice_line_items, :item_tax_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_tds_amount)
      add_column :invoice_line_items, :item_tds_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_net_amount)
      add_column :invoice_line_items, :item_net_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_billable_amount)
      add_column :invoice_line_items, :item_billable_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_gross_amount_converted)
      add_column :invoices, :invoice_gross_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_discount_amount_converted)
      add_column :invoices, :invoice_discount_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_taxable_amount_converted)
      add_column :invoices, :invoice_taxable_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_tax_amount_converted)
      add_column :invoices, :invoice_tax_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_tds_amount_converted)
      add_column :invoices, :invoice_tds_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_freight_amount_converted)
      add_column :invoices, :invoice_freight_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_sub_total_amount_converted)
      add_column :invoices, :invoice_sub_total_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_roundoff_amount_converted)
      add_column :invoices, :invoice_roundoff_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_advance_paid_amount)
      add_column :invoices, :invoice_advance_paid_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_advance_paid_amount_converted)
      add_column :invoices, :invoice_advance_paid_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_total_amount_converted)
      add_column :invoices, :invoice_total_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_net_total_amount)
      add_column :invoices, :invoice_net_total_amount, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_net_total_amount_converted)
      add_column :invoices, :invoice_net_total_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_paid_outside_amount_converted)
      add_column :invoices, :invoice_paid_outside_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoices, :invoice_balance_due_converted)
      add_column :invoices, :invoice_balance_due_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end

    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_gross_amount_converted)
      add_column :invoice_line_items, :item_gross_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_discount_amount_converted)
      add_column :invoice_line_items, :item_discount_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_taxable_amount_converted)
      add_column :invoice_line_items, :item_taxable_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_tax_amount_converted)
      add_column :invoice_line_items, :item_tax_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_tds_amount_converted)
      add_column :invoice_line_items, :item_tds_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_net_amount_converted)
      add_column :invoice_line_items, :item_net_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end
    unless ActiveRecord::Base.connection.column_exists?(:invoice_line_items, :item_billable_amount_converted)
      add_column :invoice_line_items, :item_billable_amount_converted, :decimal, :precision => 20, :scale => 5, if_not_exists: true
    end

  end
end
