class AddDisabledByToCard < ActiveRecord::Migration
  def change
    add_column :cards, :disabled_by_role_id, :integer, references: :user_role, index: true, foreign_key: true
  end
end
