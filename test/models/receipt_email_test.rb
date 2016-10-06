# == Schema Information
#
# Table name: receipt_emails
#
#  id          :integer          not null, primary key
#  subject     :string(255)
#  body        :text(65535)
#  raw_text    :text(65535)
#  raw_html    :text(65535)
#  raw_headers :text(65535)
#  sent_at     :datetime
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


require 'test_helper'

class ReceiptEmailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
