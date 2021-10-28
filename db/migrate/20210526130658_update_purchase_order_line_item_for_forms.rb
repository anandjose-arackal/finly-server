class UpdatePurchaseOrderLineItemForForms < ActiveRecord::Migration[6.0]
  def change

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_number)
      add_column :purchase_order_items, :item_number, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :product_type_id)
      add_column :purchase_order_items, :product_type_id, :integer
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :gl_code)
      add_column :purchase_order_items, :gl_code, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_rate)
      add_column :purchase_order_items, :item_rate, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :tax_percentage)
      add_column :purchase_order_items, :tax_percentage, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_gross_amount)
      add_column :purchase_order_items, :item_gross_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_gross_amount)
      add_column :purchase_order_items, :reporting_item_gross_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_discount_amount)
      add_column :purchase_order_items, :item_discount_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_discount_amount)
      add_column :purchase_order_items, :reporting_item_discount_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_taxable_amount)
      add_column :purchase_order_items, :item_taxable_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_taxable_amount)
      add_column :purchase_order_items, :reporting_item_taxable_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_tax_amount)
      add_column :purchase_order_items, :item_tax_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_tax_amount)
      add_column :purchase_order_items, :reporting_item_tax_amount, :decimal, precision: 20, scale: 5
    end

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_tds_amount)
    #   add_column :purchase_order_items, :item_tds_amount, :decimal, precision: 20, scale: 5
    # end

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_tds_amount)
    #   add_column :purchase_order_items, :reporting_item_tds_amount, :decimal, precision: 20, scale: 5
    # end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_net_amount)
      add_column :purchase_order_items, :item_net_amount, :decimal, precision: 20, scale: 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_net_amount)
      add_column :purchase_order_items, :reporting_item_net_amount, :decimal, precision: 20, scale: 5
    end

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :item_billable_amount)
    #   add_column :purchase_order_items, :item_billable_amount, :decimal, precision: 20, scale: 5
    # end

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_order_items, :reporting_item_billable_amount)
    #   add_column :purchase_order_items, :reporting_item_billable_amount, :decimal, precision: 20, scale: 5

  end
end
