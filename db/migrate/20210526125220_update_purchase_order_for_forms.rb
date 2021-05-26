class UpdatePurchaseOrderForForms < ActiveRecord::Migration[6.0]
  def change
    # Multi Currency

    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :conversion_date)
      add_column :purchase_orders, :conversion_date, :date
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_currency_id)
      add_column :purchase_orders, :reporting_currency_id, :integer
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :base_currency_id)
      add_column :purchase_orders, :base_currency_id, :integer
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :conversion_rate)
      add_column :purchase_orders, :conversion_rate, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :payment_term_days)
      add_column :purchase_orders, :payment_term_days, :integer, default: 0
    end

    # Vendor Details
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_trade_name)
      add_column :purchase_orders, :vendor_trade_name, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_sequence_id)
      add_column :purchase_orders, :vendor_sequence_id, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_country)
      add_column :purchase_orders, :vendor_country, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_gstin)
      add_column :purchase_orders, :vendor_gstin, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_pan)
      add_column :purchase_orders, :vendor_pan, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_bank_account_number)
      add_column :purchase_orders, :vendor_bank_account_number, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_bank_account_ifsc)
      add_column :purchase_orders, :vendor_bank_account_ifsc, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :vendor_bank_account_swift_code)
      add_column :purchase_orders, :vendor_bank_account_swift_code, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :billing_address_name)
      add_column :purchase_orders, :billing_address_name, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :billing_address_gstin)
      add_column :purchase_orders, :billing_address_gstin, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :shipping_address_name)
      add_column :purchase_orders, :shipping_address_name, :string
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :shipping_address_gstin)
      add_column :purchase_orders, :shipping_address_gstin, :string
    end

    # Amount Details
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_gross_amount)
      add_column :purchase_orders, :po_gross_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_gross_amount)
      add_column :purchase_orders, :reporting_po_gross_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_discount_amount)
      add_column :purchase_orders, :po_discount_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_discount_amount)
      add_column :purchase_orders, :reporting_po_discount_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_taxable_amount)
      add_column :purchase_orders, :po_taxable_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_taxable_amount)
      add_column :purchase_orders, :reporting_po_taxable_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_tax_amount)
      add_column :purchase_orders, :po_tax_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_tax_amount)
      add_column :purchase_orders, :reporting_po_tax_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_sub_total_amount)
      add_column :purchase_orders, :po_sub_total_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_sub_total_amount)
      add_column :purchase_orders, :reporting_po_sub_total_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_roundoff_amount)
      add_column :purchase_orders, :po_roundoff_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_roundoff_amount)
      add_column :purchase_orders, :reporting_po_roundoff_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_total_amount)
      add_column :purchase_orders, :po_total_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_total_amount)
      add_column :purchase_orders, :reporting_po_total_amount, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :po_balance_due)
      add_column :purchase_orders, :po_balance_due, :decimal, precision: 20, scale: 5
    end
    
    unless ActiveRecord::Base.connection.column_exists?(:purchase_orders, :reporting_po_balance_due)
      add_column :purchase_orders, :reporting_po_balance_due, :decimal, precision: 20, scale: 5
    end
        
  end
end
