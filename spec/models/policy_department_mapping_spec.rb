# == Schema Information
#
# Table name: policy_department_mappings
#
#  id            :integer          not null, primary key
#  policy_id     :integer          not null
#  department_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enabled       :boolean
#

require 'rails_helper'

RSpec.describe PolicyDepartmentMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
