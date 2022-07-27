class ChangePreviewRegistrationReferer < ActiveRecord::Migration[6.0]
  def change
    change_column :preview_registrations, :referrer, :text
  end
end
