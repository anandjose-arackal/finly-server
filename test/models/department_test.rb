# == Schema Information
#
# Table name: departments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  company_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  is_deleted      :boolean          default(FALSE), not null
#  ancestry        :string(255)
#  cost_center_id  :integer
#  deleted_at      :datetime
#  department_code :string(255)
#

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
