class RenameEventToNotifierType < ActiveRecord::Migration
  def change
    rename_table :events, :notifier_types
  end
end
