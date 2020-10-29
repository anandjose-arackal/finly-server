class CreateCustomFieldSelection < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_field_selections do |t|
      t.uuid :uuid
      t.string :form_entity_choice_id, index: true, foreign_key: true
      t.string :form_custom_field_id, index: true, foreign_key: true
      t.datetime :deleted_at, index: true
    end
  end
end
