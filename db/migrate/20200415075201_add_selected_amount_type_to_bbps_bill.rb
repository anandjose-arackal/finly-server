class AddSelectedAmountTypeToBbpsBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :selected_amount_type, :string, default: :base_amount
  end
end
