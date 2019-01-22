class AddSourceAccountToAutoReload < ActiveRecord::Migration[4.2]
  def change
    add_column :auto_reload_configs, :source_account_id, :integer, polymorphic: true
    add_column :auto_reload_configs, :source_account_type, :string, polymorphic: true
  end
end
