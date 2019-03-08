# == Schema Information
#
# Table name: policy_user_role_purpose_mappings
#
#  id         :integer          not null, primary key
#  policy_id  :integer
#  user_id    :integer
#  role_id    :integer
#  purpose_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe PolicyUserRolePurposeMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
