class AddGlCodeToMoneyRequestItemCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :money_request_item_categories, :gl_code, :string
  end
end
