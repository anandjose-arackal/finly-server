# == Schema Information
#
# Table name: card_limits
#
#  id                  :integer          not null, primary key
#  card_restriction_id :integer
#  transaction_limit   :integer
#  period_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  budget_id           :integer
#  limit_type_id       :integer
#

class CardLimit < ActiveRecord::Base
  belongs_to :card_restriction

  belongs_to :budget, class_name: "Amount"
  belongs_to :period

  belongs_to :limit_type_id, class_name: "ChannelType"

  delegate :period_name, to: :period

  accepts_nested_attributes_for :budget
end
