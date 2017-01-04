class AddMothersMaidenName < ActiveRecord::Migration
  def change
    add_column :users, :mothers_maiden_name, :string
    remove_column :users, :maiden_name
  end
end
