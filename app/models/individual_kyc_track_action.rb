# == Schema Information
#
# Table name: individual_kyc_track_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IndividualKycTrackAction < ApplicationRecord
  include Seedable

  validates :name, presence: true

  def self.values
    [:pending, :retract, :submit, :approve, :final_approve, :upgraded, :reject, :download]
  end

end
