# action to export a report as xml
# params:
# report_ids: ids of the report to be exported

class Export::Reports::AsXml < Export::Reports::Base

  attr_accessor :reports, :preferences, :result, :report_names, :default_column_names, :custom_field_column_names,
                :column_names, :data

  # this will override the default behaviour of this class for Consul and stanza living
  def personalizer
    {
        post_process: {
            before: Personalizer::Process.new([:export, :reports], :as_xml, self)
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
    self.custom_field_column_names = extract_custom_field_names(reports)
    self.preferences = user.company.export_preferences
  end

  def authorize
    unless reports
      messages[:error] << "Reports to export not found."
    end
  end

  def process
    self.column_names = default_column_names + custom_field_column_names
    self.data = []
    reports.each do |r|
      r.expenses.each do |e|
        self.data << retrieve_data(preferences, r, e, custom_field_column_names)
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
    Export::Base::ExportPresenter.new(user, {header: self.column_names, data: self.data, report_names: report_names}, messages)
  end

end
