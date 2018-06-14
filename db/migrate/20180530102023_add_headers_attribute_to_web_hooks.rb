class AddHeadersAttributeToWebHooks < ActiveRecord::Migration
  def change
    add_column :web_hooks, :headers, :text
  end
end
