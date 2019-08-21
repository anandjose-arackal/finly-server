class AddTdsEnabledToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :tds_applicable, :boolean
  end
end
