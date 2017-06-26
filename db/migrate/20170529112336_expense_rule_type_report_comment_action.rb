class ExpenseRuleTypeReportCommentAction < ActiveRecord::Migration
  def up
    if Company.count > 0
      ExpenseRuleType.seed_data
      ReportCommentAction.seed_data
    end
  end

  def down
    ExpenseRuleType.find(4).delete
    ReportCommentAction.find(24).delete
    ReportCommentAction.find(25).delete
  end
end