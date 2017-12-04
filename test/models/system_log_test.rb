# == Schema Information
#
# Table name: system_logs
#
#  id                :integer          not null, primary key
#  log_resource_id   :integer          not null
#  log_resource_type :string(255)      not null
#  type_id           :integer          not null
#  value             :text(65535)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class SystemLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
