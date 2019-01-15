# == Schema Information
#
# Table name: receipts
#
#  id                 :integer          not null, primary key
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
#  to_be_transcribed  :boolean          default(FALSE)
#  hard_copy_received :boolean          default(TRUE)
#  sourcable_id       :integer
#  sourcable_type     :integer
#  is_deleted         :boolean          default(FALSE)
#  created_by_id      :integer
#  modified_by_id     :integer
#


require 'test_helper'

class ReceiptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
