class AddDisplayKeyToFormEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :display_key, :boolean, default: false
  end
end
