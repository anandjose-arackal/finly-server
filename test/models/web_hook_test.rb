# == Schema Information
#
# Table name: web_hooks
#
#  id                 :integer          not null, primary key
#  url                :text(65535)      not null
#  secret             :string(255)
#  created_by_user_id :integer          not null
#  company_id         :integer          not null
#  is_deleted         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  headers            :text(65535)
#  deleted_at         :datetime
#

require 'test_helper'

class WebHookTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
