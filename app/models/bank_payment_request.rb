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
end
