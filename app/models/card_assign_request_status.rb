# == Schema Information
#
# Table name: card_assign_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardAssignRequestStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:submitted, :processing, :approved, :assigned, :rejected, :cancelled]
  end

end
