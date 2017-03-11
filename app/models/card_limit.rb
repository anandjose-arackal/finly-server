# == Schema Information
#
# Table name: card_limits
#
#  id                  :integer          not null, primary key
#  card_restriction_id :integer
#  transactions        :integer
#  period_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  budget              :decimal(10, )
#  limit_type_id       :integer
#  allowed             :boolean
#

class CardLimit < ActiveRecord::Base
  belongs_to :card_restriction

  belongs_to :period

  belongs_to :limit_type, class_name: "ChannelType"

  delegate :period_name, to: :period

  

  scope :atm_limits, -> {where limit_type_id: ChannelType.id_for(:atm)}
  scope :ecom_pos_limits, -> {where limit_type_id: ChannelType.id_for(:ecom_pos)}
end
