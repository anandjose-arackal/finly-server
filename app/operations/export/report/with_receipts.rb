class Export::Report::WithReceipts < Export::Report::Base

  attr_accessor :reports, :preferences, :result, :report_names, :default_column_names, :custom_field_column_names, :files

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def init
    report_presenter = ::Report::Index.(user, params)
    id = (params[:report_id] or params[:report_ids]).split(',') rescue nil
    self.reports = report_presenter&.reports
    if id.present?
      self.reports = self.reports&.with_id(id)
    end
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names(reports)
    self.preferences = user.company.export_preferences
  end

  def authorize
    unless reports
      messages[:error] << 'Report not found'
    end
  end

  def validate

  end

  def process
    cf_data = generate_custom_field_data reports
    cf_headers = cf_data[:headers]
    self.files = []
    headers = (default_column_names + cf_headers)
    contents = []
    # csv << column_names
    reports.each do |r|
      r.expenses.each do |expense|
        contents << retrieve_data(preferences, r, expense, cf_data)
        expense.receipts&.each do |receipt|
          self.files << {name: receipt.export_image_file_name, url: receipt.image.url, dir_path: expense.report_id}
        end
      end
    end
    case params[:type]
      when 'xls'
        self.files << {name: 'finly_export.xls', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_xls}
      when 'csv'
        self.files << {name: 'finly_export.csv', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_csv}
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
    Exporter::AsZip.new(user, {name: 'export', files: self.files}, messages)
  end

end