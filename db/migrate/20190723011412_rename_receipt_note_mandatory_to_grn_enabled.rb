class RenameReceiptNoteMandatoryToGrnEnabled < ActiveRecord::Migration[5.2]
  def change
  	rename_column :feature_subscriptions, :receipt_note_mandatory, :grn_enabled
  	add_column :feature_subscriptions, :srn_enabled, :boolean, default: false
  	add_index :feature_subscriptions, :srn_enabled
  end
end
