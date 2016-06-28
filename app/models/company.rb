class Company < ActiveRecord::Base
  has_many :users
  has_many :contacts, as: :contactable
  has_one :configuration, class_name: "CompanyConfiguration", dependent: :destroy
  accepts_nested_attributes_for :configuration

  after_create :init_config_present

  validates :name, presence: true

  private
  def init_config_present
    self.build_configuration.save unless self.configuration.present?
  end
end