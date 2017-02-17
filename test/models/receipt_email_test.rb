# == Schema Information
#
# Table name: receipt_emails
#
#  id                      :integer          not null, primary key
#  subject                 :string(255)
#  sent_at                 :datetime
#  user_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  body_file_name          :string(255)
#  body_content_type       :string(255)
#  body_file_size          :integer
#  body_updated_at         :datetime
#  raw_text_file_name      :string(255)
#  raw_text_content_type   :string(255)
#  raw_text_file_size      :integer
#  raw_text_updated_at     :datetime
#  raw_html_file_name      :string(255)
#  raw_html_content_type   :string(255)
#  raw_html_file_size      :integer
#  raw_html_updated_at     :datetime
#  raw_header_file_name    :string(255)
#  raw_header_content_type :string(255)
#  raw_header_file_size    :integer
#  raw_header_updated_at   :datetime
#


require 'test_helper'

class ReceiptEmailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
