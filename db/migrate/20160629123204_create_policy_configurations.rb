class CreatePolicyConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :policy_configurations do |t|
      t.references :policy, index: true, foreign_key: true, null: false
      t.boolean :require_category, null: false, default: false
      t.boolean :default_billable_set, null: false, default: false
      t.integer :report_currency_id, :references => "currency", index: true, foreign_key: true
      t.integer :technical_contact_id, :references => "Contact", index: true, foreign_key: true
      t.boolean :mandate_expense_tagging, null: false, default: false
      t.integer :default_tag_id, :references => "PolicyTag", index: true, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
