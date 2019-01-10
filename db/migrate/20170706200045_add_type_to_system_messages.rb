class AddTypeToSystemMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :system_messages, :type, :string
  end
end
