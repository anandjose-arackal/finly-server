# == Schema Information
#
# Table name: card_load_requests
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  card_id                 :integer          not null
#  amount_id               :integer          not null
#  policy_id               :integer
#  status_id               :integer          not null
#  controlling_user_id     :integer
#  controlling_for_user_id :integer
#  loaded_by               :integer
#  loaded_at               :datetime
#  note                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class CardLoadRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
