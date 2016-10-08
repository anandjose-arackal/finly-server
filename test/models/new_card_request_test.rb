# == Schema Information
#
# Table name: new_card_requests
#
#  id                 :integer          not null, primary key
#  company_id         :integer
#  requesting_user_id :integer
#  card_type_id       :integer
#  status_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class NewCardRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
