class AddColumnsToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :controlling_level_id, :integer
    add_column :payment_agreements, :status_id, :integer
    add_column :payment_agreements, :submitted_at, :datetime
    add_column :payment_agreements, :approved_at, :datetime
    add_column :payment_agreements, :reject_note, :text
    add_column :payment_agreements, :company_id, :integer
  end
end
