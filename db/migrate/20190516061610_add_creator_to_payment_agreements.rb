class AddCreatorToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :creator_id, :integer
  end
end
