class AddRevisionReasonToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :revision_reason, :text
  end
end
