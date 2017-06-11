# == Schema Information
#
# Table name: receipt_email_senders
#
#  id                        :integer          not null, primary key
#  email_id                  :string(255)      not null
#  receipt_email_template_id :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  domain                    :string(255)      not null
#  search_term               :string(255)      not null
#

require 'test_helper'

class ReceiptEmailSenderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
