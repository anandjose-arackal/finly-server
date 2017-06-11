# == Schema Information
#
# Table name: receipt_email_data_points
#
#  id                        :integer          not null, primary key
#  amount_xpath              :text(65535)
#  amount_xpath_regex        :string(255)
#  amount_css_selector       :text(65535)
#  amount_css_selector_regex :string(255)
#  receipt_email_template_id :integer          not null
#  priority                  :decimal(10, )    default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  amount_mode_id            :integer          not null
#

require 'test_helper'

class ReceiptEmailDataPointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
