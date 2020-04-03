class BudgetManager::BudgetsTrb::Import::GenerateImportTemplate < BudgetManager::BudgetsTrb::Import::Base

  attr_accessor :company, :headers, :contents, :budget_group

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
  end

  def init
    id = params[:budget_group_id] || params[:id]
    self.budget_group = user.company.budget_groups.find_by(id: id)
    self.headers = default_headers
    self.contents = []
  end

  def validate
    if self.budget_group.blank?
      add_message :error, "Budget group cannot be blank"
      return
    end
  end

  def process
    self.budget_group.budget_group_criteria.each do |budget_group_criteria|
      budget_group_criteria.children.each do |child_group_criteria|
        child_group_criteria.budgets.each do |budget|
          self.contents << content_for_budget(budget)
        end
      end
      budget_group_criteria.budgets.each do |budget|
        self.contents << content_for_budget(budget)
      end
    end
  end

  def success
    Exporter.new(user, {spreadsheet: {headers: headers, contents: contents}}, messages)
  end

  private

  def content_for_budget(budget)
    [
        budget.id,
        budget.budget_group_criterium.parent&.name,
        budget.budget_group_criterium.name,
        budget.start_date,
        budget.end_date,
        budget.budget_consumption.budget_amount&.value
    ]
  end

  def default_headers
    [
        "ID",
        "Parent Budget Criteria Name",
        "Budget Criteria Name",
        "Budget Start Date",
        "Budget End Date",
        "Budget Amount"
    ]
  end

end
