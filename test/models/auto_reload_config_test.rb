# == Schema Information
#
# Table name: auto_reload_configs
#
#  id                 :integer          not null, primary key
#  minimum_balance_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  enabled            :boolean          default(FALSE)
#  reloadable_id      :integer
#  reloadable_type    :string(255)
#

require 'test_helper'

class AutoReloadConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
