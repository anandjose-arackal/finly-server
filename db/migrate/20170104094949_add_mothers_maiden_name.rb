class AddMothersMaidenName < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :mothers_maiden_name, :string
    remove_column :users, :maiden_name
  end
end
