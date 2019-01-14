class AddReplacedWithToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :replaced_with_id, :integer, references: "Card", foreign_key: true, index: true
  end
end
