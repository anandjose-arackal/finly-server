# exporting a particular report as CSV
# params:
# report_ids: id of the reports that is to be exported

class Export::Report::AsCsv < Export::Report::Base

  attr_accessor :reports, :preferences, :result, :report_names, :default_column_names, :custom_field_column_names

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    report_presenter = Report::Index.(user, params)
    id = (params[:report_id] or params[:report_ids]).split(',') rescue nil
    self.reports = report_presenter.reports.with_id(id) rescue nil
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names(reports)
    # self.preferences = user.company.export_preferences
  end

  def authorize
    unless reports
      messages[:error] << "Report not found."
    end
  end

  def validate

  end

  def process
    self.result = CSV.generate do |csv|
      csv << (column_names + custom_field_column_names)
      reports.each do |r|
        r.expenses.each do |e|
          csv << retrieve_data(preferences, r, e)
          csv << retrieve_custom_field_data(custom_field_column_names, e)
        end
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
    Export::Base::ExportPresenter.new(user, {data: result, report_names: report_names}, messages)
  end

end
