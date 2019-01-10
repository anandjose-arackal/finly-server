class AddDisabledByToCard < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :disabled_by_role_id, :integer, references: :user_role, index: true, foreign_key: true
    add_column :cards, :disabled_by_user_id, :integer, references: :user, index: true, foreign_key: true
  end
end
