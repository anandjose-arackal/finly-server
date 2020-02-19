# == Schema Information
#
# Table name: payment_agreement_types
#
#  id         :bigint           not null, primary key
#  name       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

class PaymentAgreementType < ApplicationRecord
  
  include Seedable

  def self.values
    [
      :general_invoice,
      :rental_invoice,
      :security_deposit,
      :beneficiary_payment
    ]
  end
end
