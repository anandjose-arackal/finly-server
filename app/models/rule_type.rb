# == Schema Information
#
# Table name: rule_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class RuleType < ActiveRecord::Base

  validates :name, presence: true

  def type
    self.name
  end
end
