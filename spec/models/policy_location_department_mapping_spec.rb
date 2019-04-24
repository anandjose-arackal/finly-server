# == Schema Information
#
# Table name: policy_location_department_mappings
#
#  id            :bigint(8)        not null, primary key
#  location_id   :integer
#  department_id :integer
#  policy_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :integer
#  creator_id    :integer
#

require 'rails_helper'

RSpec.describe PolicyLocationDepartmentMapping, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
