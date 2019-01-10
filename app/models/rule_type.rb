# == Schema Information
#
# Table name: rule_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class RuleType < ApplicationRecord

  validates :name, presence: true

  def type
    self.name
  end

  def self.warning_rule_id
    1
  end

  def self.blocking_rule_id
    2
  end
end
