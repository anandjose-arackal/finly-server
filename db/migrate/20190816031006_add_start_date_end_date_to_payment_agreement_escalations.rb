class AddStartDateEndDateToPaymentAgreementEscalations < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreement_escalations, :start_date, :datetime
    add_column :payment_agreement_escalations, :end_date, :datetime
    add_column :payment_agreement_escalations, :revised_amount_id, :integer
  end
end
