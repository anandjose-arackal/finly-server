# == Schema Information
#
# Table name: policy_configurations
#
#  id                      :integer          not null, primary key
#  policy_id               :integer          not null
#  require_category        :boolean          default(FALSE), not null
#  default_billable_set    :boolean          default(FALSE), not null
#  report_currency_id      :integer
#  technical_contact_id    :integer
#  mandate_expense_tagging :boolean          default(FALSE), not null
#  default_tag_id          :integer
#  active                  :boolean          default(TRUE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#


class PolicyConfiguration < ActiveRecord::Base
  include PolicyVersion
  belongs_to :policy
  belongs_to :report_currency, class_name: 'Currency'

  scope :for_policy, ->(policy_id) { find_by id: policy_id }

  validates :policy_id, presence: true, uniqueness: true

  before_save do
    self.report_currency_id = Currency.default_currency_id if self.report_currency_id.blank?
    self.require_category = false if self.require_category.nil?
    self.default_billable_set = false if self.default_billable_set.nil?
    self.mandate_expense_tagging = false if self.mandate_expense_tagging.nil?
    self.active = false if self.active.nil?
  end

end
