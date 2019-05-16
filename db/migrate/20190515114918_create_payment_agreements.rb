class CreatePaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_agreements do |t|
      t.string :order_number
      t.string :title
      t.integer :policy_id
      t.datetime :agreement_date
      t.datetime :execution_date
      t.datetime :expiration_date
      t.datetime :renewal_date
      t.text :note
      t.boolean :no_expiration

      t.timestamps
    end
  end
end
