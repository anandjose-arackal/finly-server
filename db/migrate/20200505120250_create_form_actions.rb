class CreateFormActions < ActiveRecord::Migration[5.2]
  def change
    create_table :form_condition_actions do |t|
      t.uuid
      t.references :company, index: true, null: false
      t.string :form_id, index: true, null: false
      t.string :form_condition_id, index: true, null: false
      t.string :property
      t.string :value

      t.timestamps index: true
    end
  end
end
