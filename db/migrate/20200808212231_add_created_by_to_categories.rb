class AddCreatedByToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :created_by_id, :integer, references: "users", index: true, foreign_key: true
  end
end
