# == Schema Information
#
# Table name: policy_department_mappings
#
#  id            :bigint(8)        not null, primary key
#  policy_id     :integer
#  department_id :integer
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe PolicyDepartmentMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
