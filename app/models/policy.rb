class Policy < ActiveRecord::Base
  belongs_to :company
  has_one :configuration, class_name: 'PolicyConfiguration', dependent: :destroy
  has_many :user_mapping, class_name: 'PolicyUserMapping', dependent: :destroy
  has_many :users, through: :user_mapping
  has_many :user_team_mapping, class_name: 'UserManagerMapping', dependent: :destroy

  scope :default, -> { find_by default: true }
  scope :non_default, -> { where default: false }
  scope :company, ->(company_id) { where company_id: company_id }
  scope :by_name, ->(name) { where name: name }

  validates :company_id, presence: true
  validate :valid_name
  validate :one_default_per_company

  after_create do
    self.build_configuration.save unless self.configuration.present?
  end

  private
  def valid_name
    errors.add(:name, 'cannot be blank') if name.blank? and not default
    if company_id.present? and name.present?
      errors.add(:name, 'has to be unique') if Policy.company(company_id).non_default.by_name(name).present?
    end
  end

  def one_default_per_company
    if default
      default_policy = Policy.company(company_id).default
      errors.add(:company, 'cannot have more than one default policy') if default_policy.present? and default_policy != self
    end
  end
end