# == Schema Information
#
# Table name: company_departments
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  company_id         :integer          not null
#  active             :boolean          default(TRUE)
#  is_deleted         :boolean          default(FALSE)
#  created_by_user_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#

class CompanyDepartment < ApplicationRecord
  include SoftDeletable

  belongs_to :company, optional: true
  belongs_to :created_by_user, optional: true, class_name: 'User'
  has_many :company_location_departments
  has_many :branch_locations, through: :company_location_departments

  validates :name, presence: true, uniqueness: {scope: :company_id}
  validates :created_by_user_id, presence: true
  validates :company_id, presence: true

end
