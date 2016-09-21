# action to export a report as xml
# params:
# report_ids: ids of the report to be exported

class Export::AsXml < Export::Base

  attr_accessor :reports, :preferences, :result

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    self.reports = Report.where(id: params[:report_id])
    self.preferences = user.company.export_preferences
  end

  def authorize
    unless reports
      messages[:error] << "Reports to export not found."
    end
  end

  def process
    @column_names = preferences.pluck(:name)
    @data = []
    reports.each do |r|
      r.expenses.each do |e|
        @data << retrieve_data(preferences, r, e)
      end
    end
  end

  def success
    Export::Base::ExportPresenter.new(user, {header: @column_names, data: @data}, messages)
  end


end