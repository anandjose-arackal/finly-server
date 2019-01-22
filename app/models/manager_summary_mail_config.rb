# == Schema Information
#
# Table name: manager_summary_mail_configs
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  period_id              :integer          not null
#  scheduled_day_of_month :integer
#  scheduled_day_of_week  :string(255)
#  scheduled_time         :string(255)      not null
#  entity_type            :string(255)      not null
#  application            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ManagerSummaryMailConfig < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :user_mailer_type, optional: true
  belongs_to :period, optional: true

  DAYS_OF_MONTH = [*1..31] + [nil]
  WEEK_DAYS = [nil, 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

  validates :user_id, presence: true
  validates :period_id, presence: true, :inclusion => {:in => [Period.id_for(:day), Period.id_for(:week), Period.id_for(:month)]}
  validates :scheduled_day_of_month, :inclusion => {:in => DAYS_OF_MONTH}
  validates_presence_of :scheduled_day_of_month, if: -> { period_id == Period.id_for(:month) }
  validates :scheduled_day_of_week, :inclusion => {:in => WEEK_DAYS}
  validates_presence_of :scheduled_day_of_week, if: -> { period_id == Period.id_for(:week) }
  validates :entity_type, presence: true, :inclusion => {:in => ['report', 'money_request']}
  validates :application, Application.validate_app
  validate :validate_scheduled_time

  scope :configurations_for, -> (day_of_month, day_of_week, time_slot) do
    query = StringIO.new
    query << '('
    query << "(period_id = #{Period.id_for(:day)})"
    query << " OR "
    query << "(period_id = #{Period.id_for(:week)} AND scheduled_day_of_week = '#{day_of_week}')"
    query << " OR "
    query << "(period_id = #{Period.id_for(:month)} AND scheduled_day_of_month = '#{day_of_month}')"
    query << ')'
    query << " AND "
    query << "scheduled_time = '#{time_slot}'"
    where(query.string)
  end
  scope :group_by_user, -> { group(:user_id) }
  scope :reports, -> { where entity_type: 'report' }
  scope :money_requests, -> { where entity_type: 'money_request' }
  scope :travel_requests, -> { where entity_type: 'travel_request' }

  def validate_scheduled_time
    if scheduled_time.blank?
      errors.add :time, 'cannot be empty. Please provide a time to schedule mailers'
      return
    end
    time_split = scheduled_time.split(':')
    unless time_split&.size == 2
      errors.add :time, 'is invalid'
      return
    end
    time_split_hours = time_split[0].to_i rescue nil
    time_split_minutes = time_split[1].to_i rescue nil
    if time_split_hours.nil? or time_split_minutes.nil?
      errors.add :time, 'is invalid'
      return
    end
    unless time_split_hours >= 0 and time_split_hours <= 24 and time_split_minutes >= 0 and time_split_minutes <= 60
      errors.add :time, 'is invalid'
      return
    end
    self.scheduled_time = "#{('%02d' % time_split_hours)}:#{('%02d' % time_split_minutes)}"
  end


end
