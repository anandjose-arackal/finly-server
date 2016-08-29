# == Schema Information
#
# Table name: card_load_requests
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  card_id                 :integer          not null
#  amount_id               :integer          not null
#  policy_id               :integer
#  status_id               :integer          not null
#  controlling_user_id     :integer
#  controlling_for_user_id :integer
#  loaded_by               :integer
#  loaded_at               :datetime
#  note                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class CardLoadRequest < ActiveRecord::Base
  include OperationCallbacks

  belongs_to :status, class_name: 'CardLoadRequestStatus'
  belongs_to :user
  belongs_to :card
  belongs_to :amount
  belongs_to :loaded_by, class_name: 'User'
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_for_user, class_name: 'User'

  has_many :tracks, class_name: 'CardLoadRequestTrack', foreign_key: :card_load_request_id
  has_many :comments, class_name: 'CardLoadRequestComment', foreign_key: :card_load_request_id

  scope :with_id, ->(id) { where id: id }

  accepts_nested_attributes_for :amount

  # Used to retrieve all the users associated with this report. If user before is provided,
  # it provides a list of all users who interacted with the report before this given user. Mainly used for reject_to
  def associated_users(user_before = nil, ordered = false)
    return nil if tracks.blank?
    trackings = tracks.without_take_control_action
    if user_before.present?
      track = trackings.with_action_user(user_before.id).first
      unless track.blank?
        trackings = trackings.created_before(track.created_at)
      end
    end
    user_ids = trackings.map(&:action_user_id).uniq
    if controlling_user_id.present? and (user_before.blank? or user_before.id != controlling_user_id)
      if controlling_for_user_id.present?
        user_ids << controlling_for_user_id
      else
        user_ids << controlling_user_id
      end
    end
    if user_ids.size > 0
      # Order is MySQL Specific
      user_ids = user_ids.reverse!
      user_ids.reject! { |id| id.blank? }
      return User.where(id: user_ids).where(company_id: self.user.company_id).order("field(id,#{user_ids.join(',')})")
    end
    nil
  end

  def processing?
    status_id == CardLoadRequestStatus.processing_id
  end

  def retracted?
    status_id == CardLoadRequestStatus.retracted_id
  end

  def rejected?
    status_id == CardLoadRequestStatus.rejected_id
  end

  def credited?
    status_id == CardLoadRequestStatus.credited_id
  end

  def can_submit?
    retracted? or rejected?
  end

  def can_retract?
    processing?
  end

  def can_delete?
    retracted? or rejected?
  end

  def can_unapprove?
    credited?
  end

end
