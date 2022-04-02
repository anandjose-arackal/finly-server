class UpdatePurchaseRequestItemsForForms < ActiveRecord::Migration[6.0]
  def change

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :item_description)
      add_column :purchase_request_items, :item_description, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :item_number)
      add_column :purchase_request_items, :item_number, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :item_rate)
      add_column :purchase_request_items, :item_rate, :decimal, :precision => 20, :scale => 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :rate)
      add_column :purchase_request_items, :rate, :decimal, :precision => 20, :scale => 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :item_gross_amount)
      add_column :purchase_request_items, :item_gross_amount, :decimal, :precision => 20, :scale => 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_request_items, :reporting_item_gross_amount)
      add_column :purchase_request_items, :reporting_item_gross_amount, :decimal, :precision => 20, :scale => 5
    end

  end
end