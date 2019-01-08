class CreateUserDelegateMappings < ActiveRecord::Migration
  def change
    create_table :user_delegate_mappings do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :delegate_for_user_id, references: "User", foreign_key: true, index: true
      t.boolean :expense_create
      t.boolean :expense_update
      t.boolean :receipt_create
      t.boolean :receipt_add_to_expense
      t.boolean :receipt_update
      t.boolean :report_create
      t.boolean :report_submit
      t.boolean :report_retract
      t.boolean :report_update
      t.boolean :money_request_create
      t.boolean :money_request_update
      t.boolean :money_request_submit
      t.boolean :money_request_retract
      t.boolean :trip_create
      t.boolean :trip_update
      t.boolean :trip_submit
      t.boolean :trip_retract

      t.timestamps null: false
    end
  end
end
