class AddHeadersAttributeToWebHooks < ActiveRecord::Migration[4.2]
  def change
    add_column :web_hooks, :headers, :text
  end
end
