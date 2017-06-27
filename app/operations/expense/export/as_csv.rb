class Expense::Export::AsCsv < Expense::Export::Base
  attr_accessor :expenses, :result, :file_name

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    expense_presenter = Expense::Index.(user, params)
    # id = (params[:report_id] or params[:report_ids]).split(',') rescue nil
    # self.reports = report_presenter.reports.with_id(id) rescue nil
    # self.preferences = user.company.export_preferences
    self.expenses = expense_presenter.expenses
  end

  def authorize
    # unless reports
    #   messages[:error] << "Report not found."
    # end
  end

  def validate

  end

  def process
    # column_names = preferences.pluck(:name)
    column_names = ['Merchant', 'Amount', 'User', 'Mobile', 'Surcharge', 'Created At']

    self.result = CSV.generate do |csv|
      csv << column_names
      expenses.each do |expense|
        csv << retrieve_data(column_names, expense)
        # r.expenses.each do |e|
        #   csv << retrieve_data(preferences, r, e)
        # end
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
    self.file_name = 'export'
  end

  def success
    Expense::Export::Base::ExportPresenter.new(user, {data: result, file_name: file_name}, messages)
  end
end