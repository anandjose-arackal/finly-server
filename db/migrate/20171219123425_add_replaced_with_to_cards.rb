class AddReplacedWithToCards < ActiveRecord::Migration
  def change
    add_column :cards, :replaced_with_id, :integer, references: "Card", foreign_key: true, index: true
  end
end
