class RenameReplacedCardColumnInCards < ActiveRecord::Migration[4.2]
  def change
    rename_column :cards, :replaced_with_id, :replaced_card_id
  end
end