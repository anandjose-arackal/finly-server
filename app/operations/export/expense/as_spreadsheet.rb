# exporting a bunch of expenses in CSV format
# it will export details as per the default preferences of the company
# along with all the custom fields

class Export::Expense::AsSpreadsheet < Export::Expense::Base
  attr_accessor :expenses, :preferences, :result, :default_column_names, :custom_field_column_names,
                :headers

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def init
    expense_ids = params[:expense_ids]
    self.expenses = ::Expense.with_id(expense_ids).reorder(created_at: :desc).includes_export
    self.default_column_names = user.company.export_preferences.pluck(:name)
    self.custom_field_column_names = extract_custom_field_names(expenses)
    self.preferences = user.company.export_preferences
  end

  def authorize

  end

  def validate

  end

  def process
    self.headers = (default_column_names + custom_field_column_names)
    self.result = []
    self.expenses.each do |e|
      self.result << retrieve_data(preferences, e.report, e, custom_field_column_names)
    end
  end

  def post_process
    #adding report names in the name of the file

  end

  def success
    Exporter::Spreadsheet.new(user, {headers: headers, contents: result, filename: 'expenses_export'})
  end

end
