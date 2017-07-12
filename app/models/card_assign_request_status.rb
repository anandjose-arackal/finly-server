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
    [:processing, :approved, :assigned, :assigned_and_upgraded, :rejected, :cancelled]
  end

end
