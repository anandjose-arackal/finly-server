# == Schema Information
#
# Table name: payments
#
#  id                                    :integer          not null, primary key
#  amount_id                             :integer          not null
#  date                                  :date             not null
#  payment_type_id                       :integer          not null
#  initiating_user_id                    :integer          not null
#  receiving_user_id                     :integer
#  note                                  :text(65535)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  initiating_account_id                 :integer
#  initiating_account_type               :string(255)
#  receiving_account_id                  :integer
#  receiving_account_type                :string(255)
#  payment_order_id                      :integer
#  payment_status_id                     :integer          not null
#  initiating_user_type                  :string(255)
#  receiving_user_type                   :string(255)
#  payment_purpose_id                    :integer
#  reference_resource_id                 :integer
#  reference_resource_type               :string(255)
#  application                           :string(255)
#  initiating_account_closing_balance_id :integer
#  receiving_account_closing_balance_id  :integer
#  payment_mode                          :string(255)
#  initiating_account_opening_balance_id :integer
#  receiving_account_opening_balance_id  :integer
#


require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
