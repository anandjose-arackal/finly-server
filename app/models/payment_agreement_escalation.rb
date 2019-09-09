class PaymentAgreementEscalation < ApplicationRecord
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
