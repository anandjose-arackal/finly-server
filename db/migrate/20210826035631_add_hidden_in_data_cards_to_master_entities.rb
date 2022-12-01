class AddHiddenInDataCardsToMasterEntities < ActiveRecord::Migration[6.0]
  def change
    remove_column :master_entities, :show_in_data_card_as
    add_column :master_entities, :do_not_show_in_data_cards, :boolean, default: false
  end
end
