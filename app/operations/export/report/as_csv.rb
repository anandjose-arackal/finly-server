# exporting a particular report as CSV
# params:
# report_ids: id of the reports that is to be exported

class Export::Report::AsCsv < Export::Report::Base

  attr_accessor :reports, :preferences, :result

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
      messages[:error] << "Report not found."
    end
  end

  def validate

  end

  def process
    column_names = preferences.pluck(:name)
    self.result = CSV.generate do |csv|
      csv << column_names
      reports.each do |r|
        r.expenses.each do |e|
          csv << retrieve_data(preferences, r, e)
        end
      end
    end
  end

  def success
    Export::Base::ExportPresenter.new(user, {data: result}, messages)
  end

end
