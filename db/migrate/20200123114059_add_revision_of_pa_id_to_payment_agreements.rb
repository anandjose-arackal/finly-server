class AddRevisionOfPaIdToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :revision_of_pa_id, :integer
  end
end
