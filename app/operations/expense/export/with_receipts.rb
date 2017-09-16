class Expense::Export::WithReceipts < Expense::Export::Base
  attr_accessor :expenses, :data, :files

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if params[:type].blank?
      add_message :error, 'Export Type not defined'
      return
    end
  end

  def init
    expense_presenter = Expense::Index.(user, params)
    self.expenses = expense_presenter.expenses
  end

  def authorize
  end

  def validate
  end

  def process
    self.files = []
    headers = ['Merchant', 'Amount', 'User', 'Mobile', 'Surcharge', 'Created At']
    contents = []
    # csv << column_names
    expenses.each do |expense|
      contents << retrieve_data(headers, expense)
      expense.receipts&.each do |receipt|
        self.files << {name: receipt.image_file_name, path: receipt.image.path}
      end
    end
    case params[:type]
      when 'xls'
        self.files << {name: 'export', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_xls}
      when 'csv'
        self.files << {name: 'export', file_contents: Exporter::Spreadsheet.new(user, {headers: headers, contents: contents}).generate_csv}
    end
  end

  def success
    Exporter::AsZip.new(user, {name: 'export', files: self.files}, messages)
  end

end