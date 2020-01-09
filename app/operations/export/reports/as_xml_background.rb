# action to export a report as xml
# params:
# report_ids: ids of the report to be exported

class Export::Reports::AsXmlBackground < Export::Reports::Background::Base

  attr_accessor :reports, :preferences, :result, :report_names, :default_column_names, :custom_field_column_names,
                :column_names, :data, :download_url, :file_name

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
    self.reports = report_presenter&.reports
    if id.present?
      self.reports = self.reports&.with_id(id)
    end
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names
    self.preferences = user.company.export_preferences
  end

  def authorize
    unless reports.count
      messages[:error] << "Reports to export not found."
    end
  end

  def process
    self.column_names = default_column_names + custom_field_column_names
    self.data = []
    reports.includes_export.find_each(batch_size: 100) do |r|
      r.expenses.find_each(batch_size: 100) do |e|
        self.data << retrieve_data(preferences, r, e, custom_field_column_names)
      end
    end
  end

  def post_process
    #adding report names in the name of the file

    report_names = 'report_export'
    exported_xls = Exporter.new(user, {spreadsheet: {headers: self.column_names, contents: self.data}}, messages).spreadsheet_exporter.generate_xls
    exportable_file = exported_xls
    self.file_name = 'export.xls'
    self.download_url = create_temporary_link(exportable_file)
    #send_email
    Event::EReport::FileDownloadLink.(user, download_url: download_url)
  end

  def success

    # Export::Base::ExportPresenter.new(user, {header: self.column_names, data: self.data, report_names: report_names}, messages)
  end

  def create_temporary_link(file)
    return nil if file.nil?
    temp_file = File.open(self.file_name, 'wb')
    temp_file.write file
    temp_file.rewind
    # temp_file
    t = TemporaryFile.create(file: temp_file)
    File.delete(temp_file.path)
    unless t.valid?
      add_message :error, t.errors.full_messages
      return
    end
    t.file.url
  end

end
