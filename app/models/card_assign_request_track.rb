# == Schema Information
#
# Table name: card_assign_request_tracks
#
#  id                     :integer          not null, primary key
#  card_assign_request_id :integer          not null
#  action_resource_id     :integer
#  action_resource_type   :string(255)
#  action_id              :integer          not null
#  note                   :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CardAssignRequestTrack < ActiveRecord::Base
  belongs_to :card_assign_request
  belongs_to :action_resource, polymorphic: true
  belongs_to :action, class_name: 'CardAssignRequestTrackAction'

  validates :card_assign_request_id, presence: true
  validates :action_id, presence: true

  def message
    message = nil
    if action_resource.present?
      name = action_resource&.name
      case action_id
        when CardAssignRequestTrackAction.id_for(:submit)
          message = "#{name} has submitted the request"
        when CardAssignRequestTrackAction.id_for(:approve)
          message = "#{name} has approved the request"
        when CardAssignRequestTrackAction.id_for(:final_approve)
          message = "#{name} has approved the request. Request is marked as approved."
        when CardAssignRequestTrackAction.id_for(:assigned)
          if name.present?
            message = "#{name} assigned as ASC"
          else
            message = "Card #{card_assign_request.card} assigned as ASC"
          end
        when CardAssignRequestTrackAction.id_for(:assigned_upgraded)
          if name.present?
            message = "#{name} assigned card #{card_assign_request.card} as OLC"
          else
            message = "Card #{card_assign_request.card} assigned as OLC"
          end
        when CardAssignRequestTrackAction.id_for(:reject)
          message = "#{name} has rejected the request"
          if note.present?
            message += " with note: #{note}"
          end
          message = message
        when CardAssignRequestTrackAction.id_for(:cancel)
          message = 'Request cancelled'
          if name.present?
            message += " by #{name}"
          end
          message = message
        when CardAssignRequestTrackAction.id_for(:download)
          message = "#{name} has downloaded the request"
        else
          nil
      end
    end
    message
  end

end
