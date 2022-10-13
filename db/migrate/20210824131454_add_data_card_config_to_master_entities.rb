class AddDataCardConfigToMasterEntities < ActiveRecord::Migration[6.0]
  def change
    add_column :master_entities, :data_card_config, :text
  end
end
