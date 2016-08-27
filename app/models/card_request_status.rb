# == Schema Information
#
# Table name: card_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardRequestStatus < ActiveRecord::Base
end
