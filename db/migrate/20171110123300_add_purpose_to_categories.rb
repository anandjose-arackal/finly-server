class AddPurposeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :purpose_id, :integer, references: "Purpose", foreign_key: true, index: true
  end
end