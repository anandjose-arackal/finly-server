# == Schema Information
#
# Table name: payments_receivables
#
#  id                 :integer          not null, primary key
#  customer_id        :integer
#  amount_id          :integer
#  purpose            :text(65535)
#  expire_by          :date
#  company_id         :integer
#  initiating_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class PaymentsReceivableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
