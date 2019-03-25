# == Schema Information
#
# Table name: bank_payment_requests
#
#  id                           :integer          not null, primary key
#  owner_id                     :integer
#  status_id                    :integer
#  controlling_user_id          :integer
#  payment_order_id             :integer
#  name                         :string(255)
#  requested_amount_id          :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  submitted_at                 :datetime
#  controlling_user_role_id     :integer
#  description                  :text(65535)
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  require_approval             :boolean
#  is_deleted                   :boolean
#  beneficiary_type_id          :integer
#  policy_id                    :integer
#  payment_file_downloaded      :boolean          default(FALSE)
#  auto_approved                :boolean
#  api_initiated                :boolean          default(FALSE)
#  deleted_at                   :datetime
#  controlling_level_id         :integer
#  approved_at                  :datetime
#  company_id                   :integer
#

require 'test_helper'

class BankPaymentRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
