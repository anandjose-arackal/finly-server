# == Schema Information
#
# Table name: payment_orders
#
#  id                        :integer          not null, primary key
#  payment_order_type_id     :integer          not null
#  scheduled_at              :date
#  processed_at              :datetime
#  initiating_user_id        :integer          not null
#  payment_order_status_id   :integer          not null
#  payment_file_file_name    :string(255)
#  payment_file_content_type :string(255)
#  payment_file_file_size    :integer
#  payment_file_updated_at   :datetime
#  company_id                :integer          not null
#  amount_requested_id       :integer          not null
#  amount_processed_id       :integer          not null
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class PaymentOrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
