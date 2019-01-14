class CreatePostOperationActions < ActiveRecord::Migration[4.2]
  def change
    create_table :post_operation_actions do |t|
      t.string :operation, index: true, null: false
      t.text :payload
      t.integer :post_operatable_id, index: true, null: false
      t.string :post_operatable_type, index: true, null: false

      t.timestamps null: false
    end
  end
end
