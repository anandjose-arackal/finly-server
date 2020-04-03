class BudgetManager::BudgetsTrb::Import::ImportBudgets < BudgetManager::BudgetsTrb::Import::Base

  attr_accessor :parsed_data, :file, :errors, :headers, :contents, :sheets

  def init
    self.file = params[:file]
    self.headers = default_headers
    self.contents = []
    self.sheets = []
    begin
      self.parsed_data = ImportUtil.load_spreadsheet_quickly(file, default_headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError, RuntimeError => e
      case e.class.name
      when 'RuntimeError'
        add_message :error, e.message
      else
        add_message :error, "File Format error. Please re-save your Excel sheet in Microsoft 2007 format or greater."
      end
    end
  end

  def validate
    if self.parsed_data.blank?
      add_message :error, "Nothing to process"
      return
    end
  end

  def process
    self.parsed_data.each do |data|
      result_row = data.values
      budget_id = data[:id]
      budget = user.company.budgets.find_by(id: budget_id)
      if budget.blank?
        result_row += "Budget not found"
      end
      amount = data[:budget_amount]
      unless budget.budget_amount.update(value: amount)
        result_row += budget.errors.full_messages
      end
      self.contents << result_row
    end

    self.sheets << {
        item_headers: self.headers,
        item_contents: self.contents,
        name: "Budget Import"
    }
  end

  def success
    Exporter.new(user, {xlsx: {headers: headers, contents: contents, sheets: self.sheets}}, messages)
  end

  private

  def default_headers
    [
        :id,
        :parent_budget_criteria,
        :budget_criteria,
        :budget_start_date,
        :budget_end_date,
        :budget_amount
    ]
  end
end