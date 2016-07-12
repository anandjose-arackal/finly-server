# == Schema Information
#
# Table name: reports
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  user_id                 :integer          not null
#  report_status_id        :integer          not null
#  policy_id               :integer
#  submitted_at            :datetime
#  controlling_user_id     :integer          not null
#  controlling_for_user_id :integer
#  forwarding_to_id        :integer
#  memo                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :status, class_name: 'ReportStatus', foreign_key: :report_status_id
  belongs_to :policy
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :forwarding_to, class_name: 'User'
  has_many :tracks, class_name: 'ReportTrack'
  has_many :expenses
  has_many :comments, class_name: 'ReportComment'

  validates :user, presence: true
  validates :status, presence: true
  validates :controlling_user, presence: true

  before_save do
    if self.name.blank?
      self.name = Report.get_default_name(self.user)
    end
  end

  # Used to retrieve all the users associated with this report. If user before is provided,
  # it provides a list of all users who interacted with the report before this given user. Mainly used for reject_to
  def associated_users(user_before = nil)
    return nil if tracks.blank?
    trackings = tracks.without_take_control_action
    if user_before.present?
      track = trackings.find_by(action_user_id: user_before.id)
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
      return User.where(id: user_ids).where(company_id: self.user.company_id).order("field(id,#{user_ids.join(',')})")
    end
    nil
  end

  def self.get_default_name(user)
    "#{user.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end

  def open?
    self.status.id == 1
  end

  def retracted?
    self.status.id == 2
  end

  def rejected?
    self.status.id == 3
  end

  def processing?
    self.status.id == 4
  end

  def approved?
    self.status.id == 5
  end

  def reimbursed?
    self.status.id == 6
  end

  def reimbursement_confirmed?
    self.status.id == 7
  end

  def closed?
    self.status.id == 8
  end

end
