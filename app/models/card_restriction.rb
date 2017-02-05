# == Schema Information
#
# Table name: card_restrictions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  channel_atm          :boolean
#  channel_pos          :boolean
#  channel_online       :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  channel_ecom_pos     :boolean
#  mcc_group_id         :integer
#  mcc_restriction_type :string(255)
#

class CardRestriction < ActiveRecord::Base
  belongs_to :user, dependent: :destroy

  belongs_to :mcc_group

  has_many :card_limits

  accepts_nested_attributes_for :card_limits

  delegate :mcc_group_name, to: :mcc_group

end
