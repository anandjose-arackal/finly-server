class CreateMoneyRequestProcessorMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :money_request_processor_mappings do |t|
      t.integer :processor_id, references: 'MoneyRequestProcessor', index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :processor_accountable_id
      t.string :processor_accountable_type
      t.references :amount, index: true, foreign_key: true, null: false
      t.datetime :completed_at
      t.boolean :marked_as_completed, default: false
      t.integer :status_id, references: 'MoneyRequestProcessorStatus', index: true, foreign_key: true, null: false
      t.references :payment, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_column :money_requests, :money_request_processor_mapping_id, :integer, references: 'MoneyRequestProcessorMapping', index: true, foreign_key: true
  end
end
