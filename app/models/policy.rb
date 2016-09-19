# == Schema Information
#
# Table name: policies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  company_id :integer
#  owner_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  default    :boolean          default(FALSE), not null
#

class Policy < ActiveRecord::Base
  belongs_to :company
  has_one :configuration, class_name: 'PolicyConfiguration', dependent: :destroy
  has_many :user_mapping, class_name: 'PolicyUserMapping', dependent: :destroy
  has_many :users, through: :user_mapping
  has_many :user_team_mapping, class_name: 'UserManagerMapping', dependent: :destroy

  has_many :reports
  has_many :money_requests

  has_many :expense_rules, dependent: :destroy
  has_many :budget_rules, dependent: :destroy

  scope :default, -> { where default: true }
  scope :non_default, -> { where default: false }
  scope :company, ->(company_id) { where company_id: company_id }
  scope :by_name, ->(name) { where name: name }
  scope :with_id, -> (id) { where id: id }

  delegate :expense_rules_count, to: :expense_rules
  delegate :budget_rules_count, to: :budget_rules

  validates :company_id, presence: true
  validate :valid_name
  validate :one_default_per_company

  has_paper_trail

  def admins
    admin_mapping_ids = self.user_mapping.admin.pluck(:user_id)
    User.where(id: admin_mapping_ids)
  end

  after_create do
    self.build_configuration.save unless self.configuration.present?
  end

  def expense_rules_count
    self.expense_rules.count
  end

  def budget_rules_count
    self.budget_rules.count
  end

  def rules_count
    count = 0
    count += self.expense_rules.count
    count += self.budget_rules.count
    return count
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
