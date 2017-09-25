# == Schema Information
#
# Table name: summary_mail_configurations
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  period_id              :integer
#  scheduled_day_of_month :integer
#  scheduled_day_of_week  :string(255)
#  scheduled_time         :string(255)
#  personal               :boolean
#  application            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class SummaryMailConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :period

  scope :configurations_for, -> (day_of_month, day_of_week, time_slot) do
    query = StringIO.new
    query << '('
      query << "(period_id = #{Period.id_for(:day)})"
      query << " OR "
      query << "(period_id == #{Period.id_for(:week)} AND scheduled_day_of_week == #{day_of_week})"
      query << " OR "
      query << "(period_id == #{Period.id_for(:month)} AND scheduled_day_of_month == #{day_of_month})"
    query << ')'
    query << " AND "
    query << "scheduled_time == #{time_slot}"
    where query.string
  end
end
