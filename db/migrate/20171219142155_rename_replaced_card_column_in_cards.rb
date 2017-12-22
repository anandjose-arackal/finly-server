class RenameReplacedCardColumnInCards < ActiveRecord::Migration
  def change
    rename_column :cards, :replaced_with_id, :replaced_card_id
  end
end