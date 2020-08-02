class AddUuidToFormRules < ActiveRecord::Migration[5.2]
  def change
    add_column :form_rules, :uuid, :string, limit: 36, index: true, null: false
    add_column :form_condition_actions, :deleted_at, :datetime, index: true
  end
end
