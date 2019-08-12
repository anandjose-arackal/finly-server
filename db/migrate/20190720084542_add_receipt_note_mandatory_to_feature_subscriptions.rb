class AddReceiptNoteMandatoryToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :receipt_note_mandatory, :boolean, default: true
    add_index :feature_subscriptions, :receipt_note_mandatory
  end
end
