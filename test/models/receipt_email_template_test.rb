# == Schema Information
#
# Table name: receipt_email_templates
#
#  id                  :integer          not null, primary key
#  name                :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  default_currency_id :integer          not null
#

require 'test_helper'

class ReceiptEmailTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
