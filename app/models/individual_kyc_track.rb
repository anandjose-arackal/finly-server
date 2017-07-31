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

  scope :with_individual_kyc, -> (individual_kyc_id) { where individual_kyc_id: individual_kyc_id }
  scope :created_after, -> (datetime) { where 'created_at >= ?', datetime }
  scope :with_action_admin_resource, -> (admin_user_id) { where action_resource_id: admin_user_id, action_resource_type: 'AdminUser' }
  scope :with_action, ->(action_id) { where action_id: action_id }
  scope :created_after, -> (datetime) { where 'created_at >= ?', datetime }

  def message
    msg = nil
    if action_resource.present?
      name = action_resource&.name
      case action_id
        when IndividualKycTrackAction.id_for(:submit)
          msg = "#{name} has submitted the request"
        when IndividualKycTrackAction.id_for(:approve)
          msg = "#{name} has approved the request"
        when IndividualKycTrackAction.id_for(:final_approve)
          msg = "#{name} has approved the request. Request is marked as approved."
        when IndividualKycTrackAction.id_for(:upgraded)
          if name.present?
            msg = "#{name} has upgraded user account as OLC"
          else
            msg = "Account upgraded as OLC"
          end
        when IndividualKycTrackAction.id_for(:reject)
          msg = "#{name} has rejected the request"
          if note.present?
            msg += " with note: #{note}"
          end
          msg = msg
        when IndividualKycTrackAction.id_for(:retract)
          msg = 'Request retracted'
          if name.present?
            msg += " by #{name}"
          end
        when IndividualKycTrackAction.id_for(:download)
          msg = "#{name} has downloaded the request"
      end
    end
    msg
  end

end
