# == Schema Information
#
# Table name: individual_kyc_tracks
#
#  id                   :integer          not null, primary key
#  individual_kyc_id    :integer          not null
#  action_resource_id   :integer
#  action_resource_type :string(255)
#  action_id            :integer          not null
#  note                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class IndividualKycTrack < ActiveRecord::Base
  belongs_to :individual_kyc
  belongs_to :action_resource, polymorphic: true
  belongs_to :action, class_name: 'IndividualKycTrackAction'

  validates :individual_kyc_id, presence: true
  validates :action_id, presence: true

end
