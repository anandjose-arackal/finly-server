# == Schema Information
#
# Table name: bank_payment_request_trail_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankPaymentRequestTrailAction < ApplicationRecord

  include Seedable

  def self.values
    [:submit, :approve, :unapprove, :retract, :reject, :credit, :take_control, :approve_and_forward, :mark_as_credited, :return_control]
  end
end