class RenameEventToNotifierType < ActiveRecord::Migration[4.2]
  def change
    rename_table :events, :notifier_types
  end
end
