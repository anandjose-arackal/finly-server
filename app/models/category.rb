# == Schema Information
#
# Table name: categories
#
#  id           :integer          not null, primary key
#  company_id   :integer          not null
#  name         :string(255)      not null
#  gl_code      :string(255)
#  payroll_code :string(255)
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Category < ActiveRecord::Base
  belongs_to :company

  validates :company_id, presence: true
  validates :name, presence: true

  # returns the name of the category if it's active
  def category_name
    return self.name if self.active
    false
  end

  scope :active, -> {where active: true}
end
