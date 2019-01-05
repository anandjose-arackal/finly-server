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

class CompanyLocationDepartment < ApplicationRecord
  belongs_to :branch_location, optional: true
  belongs_to :company_department, optional: true
end
