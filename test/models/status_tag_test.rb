# == Schema Information
#
# Table name: status_tags
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  display_name    :string(255)
#  description     :string(255)
#  font_icon       :string(255)
#  font_icon_color :string(255)
#  icon_path       :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class StatusTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
