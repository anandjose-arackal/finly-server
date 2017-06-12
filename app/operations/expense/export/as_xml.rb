class Expense::Export::AsXml < Expense::Export::Base
  attr_accessor :expenses, :data, :file_name, :column_names

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
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
    self.column_names = ['Merchant', 'Amount', 'User', 'Mobile', 'Surcharge', 'Created At']
    @data = []
    # csv << column_names
    expenses.each do |expense|
      @data << retrieve_data(column_names, expense)
    end
  end

  def post_process
    self.file_name = 'export'
  end

  def success
    Expense::Export::Base::ExportPresenter.new(user, {data: data, file_name: file_name, header: column_names}, messages)
  end
end