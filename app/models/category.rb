# == Schema Information
#
# Table name: categories
#
#  id                              :integer          not null, primary key
#  company_id                      :integer          not null
#  name                            :string(255)      not null
#  gl_code                         :string(255)
#  payroll_code                    :string(255)
#  active                          :boolean          default(TRUE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  external_category_type          :string(255)
#  external_id                     :string(255)
#  external_integration_type       :string(255)
#  external_updated_at             :datetime
#  external_additional_information :text(65535)
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
  scope :others, -> { where name: 'others' }

end
