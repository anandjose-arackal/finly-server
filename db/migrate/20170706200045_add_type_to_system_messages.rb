class AddTypeToSystemMessages < ActiveRecord::Migration
  def change
    add_column :system_messages, :type, :string
  end
end
