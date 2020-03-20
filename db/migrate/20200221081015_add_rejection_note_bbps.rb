class AddRejectionNoteBbps < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :review_note, :text
    add_column :bbps_bills, :review_note, :text
    add_column :bbps_biller_subscriptions, :review_note, :text
  end
end
