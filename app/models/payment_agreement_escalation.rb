class PaymentAgreementEscalation < ApplicationRecord
  belongs_to :payment_agreement, optional: true
end
