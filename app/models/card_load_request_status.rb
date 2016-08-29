# == Schema Information
#
# Table name: card_load_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardLoadRequestStatus < ActiveRecord::Base

  def self.processing_id
    1
  end

  def self.retracted_id
    2
  end

  def self.rejected_id
    3
  end

  def self.credited_id
    4
  end

end
