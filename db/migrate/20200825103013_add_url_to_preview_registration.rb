class AddUrlToPreviewRegistration < ActiveRecord::Migration[5.2]
  def change
    add_column :preview_registrations, :url, :text
  end
end
