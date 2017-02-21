# action to export a report as xml
# params:
# report_ids: ids of the report to be exported

class Export::Report::AsXml < Export::Report::Base

  attr_accessor :reports, :preferences, :result, :report_names

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    report_presenter = Report::Index.(user, params)
    id = (params[:report_id] or params[:report_ids]).split(',') rescue nil
    self.reports = report_presenter.reports.with_id(id) rescue nil
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

  def post_process
    #adding report names in the name of the file
    names = []
    reports.each do |report|
      names << report.name
    end
    self.report_names = names.to_sentence
  end

  def success
    Export::Base::ExportPresenter.new(user, {header: @column_names, data: @data, report_names: report_names}, messages)
  end

end
