# == Schema Information
#
# Table name: document_slices
#
#  id                 :integer          not null, primary key
#  page_number        :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  receipt_id         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class DocumentSliceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
