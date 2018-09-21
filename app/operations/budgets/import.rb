class Budgets::Import < Budgets::Base

  attr_accessor :file, :sheet, :header, :content

  def init
    self.file = params[:file]
    self.sheet = ImportUtil.open_spreadsheet(self.file)
  end

  def process
    
  end

  private

  def import_fields
    [
        :budget_name => 0,
        :amount => 1,
        :start_date => 2,
        :end_date => 3,
        :categories_budgetable => 4,
        :departments_budgetable => 5,
        :locations_budgetable => 6,
        :vendors_budgetable => 7,
        :expense_y_n => 8,
        :payment_y_n => 9,
        :purchase_order_y_n => 10
    ]
  end
end