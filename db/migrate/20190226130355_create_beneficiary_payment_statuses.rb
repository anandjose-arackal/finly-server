class CreateBeneficiaryPaymentStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :beneficiary_payment_statuses do |t|
      t.string :name

      t.timestamps
    end

    BeneficiaryPaymentStatus.seed_data

  end
end
