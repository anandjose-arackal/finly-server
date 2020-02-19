class AddDisabledFlagToBbpsBiller < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_billers, :disabled, :boolean, default: false
  end
end
