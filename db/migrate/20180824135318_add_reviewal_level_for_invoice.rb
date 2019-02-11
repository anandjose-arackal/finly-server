class AddReviewalLevelForInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :policy_id, :integer, references: 'Policy', foreign_key: true, index: true
    add_column :invoices, :controlling_level_id, :integer, references: 'ReviewalLevel', foreign_key: true, index: true

    add_column :reviewal_levels, :name, :string
  end
end
