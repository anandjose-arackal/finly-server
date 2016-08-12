# == Schema Information
#
# Table name: card_load_requests
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  prepaid_card_id             :integer
#  load_amount_id              :integer
#  loaded_by                   :integer
#  loaded_at                   :datetime
#  note                        :string(255)
#  card_load_request_status_id :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class CardLoadRequest < ActiveRecord::Base
  belongs_to :card_load_request_status
  belongs_to :user
  belongs_to :card
  belongs_to :amount
  belongs_to :loaded_by, class_name: 'User'
end
