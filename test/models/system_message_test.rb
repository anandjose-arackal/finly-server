# == Schema Information
#
# Table name: system_messages
#
#  id                     :integer          not null, primary key
#  content                :text(65535)      not null
#  system_message_type_id :integer          not null
#  messagable_id          :integer
#  messagable_type        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_deleted             :boolean          default(FALSE)
#  type                   :string(255)
#

require 'test_helper'

class SystemMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
