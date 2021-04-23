# == Schema Information
#
# Table name: payment_agreement_escalations
#
#  id                   :bigint           not null, primary key
#  period_id            :integer
#  number               :integer
#  percentage_increment :decimal(10, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :integer
#  start_date           :datetime
#  end_date             :datetime
#  revised_amount_id    :integer
#  deleted_at           :datetime
#

class PaymentAgreementEscalation < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :payment_agreement, optional: true
  belongs_to :period, optional: true



  def as_json
    {
      id: self.id, 
      period_id: self.period_id, 
      number: self.number,
      percentage_increment: self.percentage_increment,
      period_name: self.period&.name
    }
  end
end
