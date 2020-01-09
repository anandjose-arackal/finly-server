# == Schema Information
#
# Table name: user_department_mappings
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class UserDepartmentMapping < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :department, optional: true
end
