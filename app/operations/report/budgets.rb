class Report::Budgets < BaseOperation
  attr_accessor :report, :budgets

  def init
    self.budgets = []
    self.report = params[:report]
  end

  def process
    self.budgets += Budget.with_user_id(report.user.id)



  end
end