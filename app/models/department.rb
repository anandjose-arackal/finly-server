# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE), not null
#

class Department < ActiveRecord::Base
  include SoftDeletable
  belongs_to :company

  has_many :user_department_mappings
  has_many :users, through: :user_department_mappings
end
