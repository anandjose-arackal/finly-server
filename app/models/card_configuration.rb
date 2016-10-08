# == Schema Information
#
# Table name: card_configurations
#
#  id                    :integer          not null, primary key
#  prepaid_card_id       :integer
#  configured_by_user_id :integer
#  card_status_id        :integer
#  end_date              :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#


class CardConfiguration < ActiveRecord::Base
  belongs_to :card_status
  belongs_to :configured_by_user, class_name: "User"
  belongs_to :prepaid_card, class_name: "Card"
end
