class PaymentAgreement < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :status_id, optional: true, class_name: 'PaymentAgreementStatus'
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id


  has_many :general_invoices, dependent: :destroy


end
