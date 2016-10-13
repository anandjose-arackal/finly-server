# == Schema Information
#
# Table name: card_configurations
#
#  id                    :integer          not null, primary key
#  prepaid_card_id       :integer
#  configured_by_user_id :integer
#  card_status_id        :integer
#  end_date              :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#


require 'test_helper'

class CardConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
