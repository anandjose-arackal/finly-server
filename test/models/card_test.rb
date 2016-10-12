# == Schema Information
#
# Table name: cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  ending_number       :string(255)      not null
#  proxy               :string(255)      not null
#  card_type_id        :integer
#  description         :text(65535)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer
#  disabled_by_role_id :integer
#  active              :boolean
#  disable_note        :text(65535)
#


require 'test_helper'

class CardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
