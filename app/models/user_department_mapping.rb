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

class UserDepartmentMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
end
