# == Schema Information
#
# Table name: receipts
#
#  id                 :integer          not null, primary key
#  expense_id         :integer
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  parent_id          :integer
#  parent_type        :string(255)
#  note               :text(65535)
#  receipt_email_id   :integer
#  transcribed        :boolean          default(FALSE)
#


require 'test_helper'

class ReceiptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
