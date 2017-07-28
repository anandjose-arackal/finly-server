# == Schema Information
#
# Table name: card_assign_request_track_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardAssignRequestTrackAction < ActiveRecord::Base
  include Seedable

  validates :name, presence: true

  def self.values
    [:submit, :approve, :final_approve, :assigned, :assigned_upgraded, :reject, :cancel, :download]
  end

end
