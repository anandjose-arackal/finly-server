class SummaryMailConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :period

  scopes :configurations_for, -> (day_of_month, day_of_week, time_slot) do
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
