# == Schema Information
#
# Table name: company_location_departments
#
#  id                    :integer          not null, primary key
#  branch_location_id    :integer          not null
#  company_department_id :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'test_helper'

class CompanyLocationDepartmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
