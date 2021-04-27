class AddColumnsToFormCurrencies < ActiveRecord::Migration[6.0]
  def change
    add_column :form_currencies, :deleted_at, :datetime, index: true
  end
end
