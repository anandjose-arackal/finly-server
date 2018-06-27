class CompanyLocationDepartment < ActiveRecord::Base
  belongs_to :branch_location
  belongs_to :company_department
end
