class CompanyDepartment < ActiveRecord::Base
  include SoftDeletable

  belongs_to :company
  belongs_to :created_by_user, class_name: 'User'
  has_many :company_location_departments
  has_many :branch_locations, through: :company_location_departments

  validates :name, presence: true, uniqueness: {scope: :company_id}
  validates :created_by_user_id, presence: true
  validates :company_id, presence: true

end
