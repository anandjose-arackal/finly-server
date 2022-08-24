class AddSizeToFormEntities < ActiveRecord::Migration[6.0]
  def change
    add_column :form_entities, :size, :string
  end
end
