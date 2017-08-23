# == Schema Information
#
# Table name: bank_payment_requests
#
#  id                  :integer          not null, primary key
#  owner_id            :integer
#  status_id           :integer
#  controlling_user_id :integer
#  payment_order_id    :integer
#  name                :string(255)
#  requested_amount_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class BankPaymentRequest < ActiveRecord::Base
  include Seedable

  def self.values
    [:open, :submitted, :retracted, :rejected, :approved, :credited]
  end

  belongs_to :bank_payment_request_status
  belongs_to :payment_order

  has_many :bank_payment_request_comments
end
