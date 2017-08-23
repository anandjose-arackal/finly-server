# == Schema Information
#
# Table name: bank_payment_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:open, :submitted, :retracted, :rejected, :approved, :credited]
  end
end
