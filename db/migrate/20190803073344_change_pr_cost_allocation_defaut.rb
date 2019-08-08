class ChangePrCostAllocationDefaut < ActiveRecord::Migration[5.2]
  # Set default to false(using third arg) and set false(using fourth arg) for old nil data
  def change
    change_column_null :purchase_requests, :cost_allocation_items, false, false
  end
end
