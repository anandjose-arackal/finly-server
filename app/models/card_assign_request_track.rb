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

  scope :with_card_assign_request, -> (card_assign_request_id) { where card_assign_request_id: card_assign_request_id }
  scope :created_after, -> (datetime) { where 'created_at >= ?', datetime }

  def message
    msg = nil
    if action_resource.present?
      name = action_resource&.name
      case action_id
        when CardAssignRequestTrackAction.id_for(:submit)
          msg = "#{name} has submitted the request"
        when CardAssignRequestTrackAction.id_for(:approve)
          msg = "#{name} has approved the request"
        when CardAssignRequestTrackAction.id_for(:final_approve)
          msg = "#{name} has approved the request. Request is marked as approved."
        when CardAssignRequestTrackAction.id_for(:assigned)
          if name.present?
            msg = "#{name} assigned as ASC"
          else
            msg = "Card #{card_assign_request.card} assigned as ASC"
          end
        when CardAssignRequestTrackAction.id_for(:assigned_upgraded)
          if name.present?
            msg = "#{name} assigned card #{card_assign_request.card} as OLC"
          else
            msg = "Card #{card_assign_request.card} assigned as OLC"
          end
        when CardAssignRequestTrackAction.id_for(:reject)
          msg = "#{name} has rejected the request"
          if note.present?
            msg += " with note: #{note}"
          end
          msg = msg
        when CardAssignRequestTrackAction.id_for(:cancel)
          msg = 'Request cancelled'
          if name.present?
            msg += " by #{name}"
          end
        when CardAssignRequestTrackAction.id_for(:download)
          msg = "#{name} has downloaded the request"
      end
    end
    msg
  end

end
