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

  # returns the name of the category
  def category_name
    self.name
  end

  scope :active, -> { where active: true }
  scope :with_id, ->(id) { where id: id }
  scope :with_name, ->(name) { where name: name }

end
