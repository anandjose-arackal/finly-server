class CreateUserPanelSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :user_panel_subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.boolean :disburse
      t.boolean :expense_management

      t.timestamps null: false
    end
  end
end
