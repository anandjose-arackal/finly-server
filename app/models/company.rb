# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(TRUE), not null
#

class Company < ActiveRecord::Base
  has_many :users
  has_many :contacts, as: :contactable
  has_many :categories, dependent: :destroy
  has_many :tags, class_name: 'CompanyTag', dependent: :destroy
  has_one :configuration, class_name: 'CompanyConfiguration', dependent: :destroy
  has_many :policies, dependent: :destroy
  accepts_nested_attributes_for :configuration

  after_create :init_config_present

  validates :name, presence: true

  private
  def init_config_present
    self.build_configuration.save unless self.configuration.present?
    self.policies.build(default: true).save unless self.policies.default.present?
  end
end
