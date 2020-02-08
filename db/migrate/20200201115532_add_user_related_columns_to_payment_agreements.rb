class AddUserRelatedColumnsToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :revised_by_id, :integer
  end
end
