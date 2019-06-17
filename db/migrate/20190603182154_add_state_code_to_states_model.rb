class AddStateCodeToStatesModel < ActiveRecord::Migration[5.2]
  def change
    add_column :states, :state_code, :string
  end
end
