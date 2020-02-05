class Expense::Exports::AsCsv < Expense::Exports::Base
  attr_accessor :expenses, :result, :file_name

  def authorize
    # unless reports
    #   messages[:error] << "Report not found."
    # end
  end

  def validate

  end

  def process
    # column_names = preferences.pluck(:name)
    self.result = CSV.generate do |csv|
      csv << (default_column_names + custom_field_column_names)
      self.expenses.each do |e|
        csv << retrieve_data(preferences, e.report, e, custom_field_column_names)
      end
    end
  end

  def post_process
    #adding report names in the name of the file
    # names = []
    # reports.each do |report|
    #   names << report.name
    # end
    # self.report_names = names.to_sentence
    # todo add time stamp to file name
    self.file_name = 'export.csv'
  end

  def success
    Expense::Exports::Base::ExportPresenter.new(user, {data: result, file_name: file_name}, messages)
  end
end