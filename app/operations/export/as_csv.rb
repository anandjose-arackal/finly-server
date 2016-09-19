# exporting a particular report as CSV
# params:
# report_ids: id of the reports that is to be exported

class Export::AsCsv < Export::Base

  attr_accessor :reports, :preferences, :result

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    self.reports = Report.where(id: params[:report_ids])
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
    # todo - figure out how to return the csv
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