class AddPurposeToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :purpose_id, :integer, references: "Purpose", foreign_key: true, index: true
  end
end