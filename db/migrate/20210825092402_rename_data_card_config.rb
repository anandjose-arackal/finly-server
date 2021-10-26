class RenameDataCardConfig < ActiveRecord::Migration[6.0]
  def change
    remove_column :form_entities, :data_card_config
    add_column :form_entities, :show_in_data_card_as, :string, index: true

    remove_column :master_entities, :data_card_config
    add_column :master_entities, :show_in_data_card_as, :string, index: true
  end
end
