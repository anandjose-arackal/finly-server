# == Schema Information
#
# Table name: card_restrictions
#
#  id                   :integer          not null, primary key
#  card_id              :integer
#  channel_atm          :boolean
#  channel_pos          :boolean
#  channel_online       :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  channel_ecom_pos     :boolean
#  mcc_group_id         :integer
#  mcc_restriction_type :string(255)
#

class CardRestriction < ApplicationRecord
  belongs_to :card, optional: true

  belongs_to :mcc_group, optional: true

  has_many :card_limits, dependent: :destroy

  accepts_nested_attributes_for :card_limits

  delegate :mcc_group_name, to: :mcc_group

end
