# == Schema Information
#
# Table name: dummy_restrictions
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  channel_atm     :boolean
#  channel_pos     :boolean
#  channel_online  :boolean
#  product_code_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DummyRestriction < ActiveRecord::Base
  belongs_to :user

  belongs_to :product_code, class_name: "ProductCombination"

  has_many :card_limits

  accepts_nested_attributes_for :card_limits
end
