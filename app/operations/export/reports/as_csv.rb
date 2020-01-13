# exporting a particular report as CSV
# params:
# report_ids: id of the reports that is to be exported

class Export::Reports::AsCsv < Export::Reports::Base

  attr_accessor :reports, :preferences, :result, :report_names, :default_column_names, :custom_field_column_names

  # this will override the default behaviour of this class for Consul alone
  def personalizer
    {
        post_process: {
            before: Personalizer::Process.new([:export, :reports], :as_csv, self)
        }
    }
  end

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def init
    report_presenter = ::Reports::Index.(user, params)
    id = (params[:report_id] or params[:report_ids]).split(',') rescue nil
    self.reports = report_presenter&.reports.includes_export
    if id.present?
      self.reports = self.reports&.with_id(id)
    end
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names
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
    # custom field data
    self.result = CSV.generate do |csv|
      csv << (default_column_names + custom_field_column_names)
      reports.each do |r|
        r.expenses.each do |e|
          csv << retrieve_data(preferences, r, e, custom_field_column_names)
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
    if names.size == 1
      self.report_names = names.to_sentence
    else
      self.report_names = "report_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
    end
  end

  def success
    Export::Base::ExportPresenter.new(user, {data: result, report_names: report_names}, messages)
  end

end
