class AddTerminatedAtToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :terminated_at, :datetime
    add_column :payment_agreements, :terminated_by_id, :integer
    add_column :payment_agreements, :termination_reason, :text
  end
end
