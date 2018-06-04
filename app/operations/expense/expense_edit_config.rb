class Expense::ExpenseEditConfig < BaseOperation
  attr_accessor :currencies, :tds_slabs, :em_tax_tracking, :company

  def init
    self.company = user.company
    self.currencies = Currency.all
    self.em_tax_tracking = company.feature_subscription.em_tax_tracking

    self.tds_slabs = []
    if em_tax_tracking
      self.tds_slabs = company.tds_slabs
    end

  end

  def success
    params[:currencies] = self.currencies
    params[:tds_slabs] = self.tds_slabs
    params[:em_tax_tracking] = self.em_tax_tracking
    Expense::ExpenseEditConfig::EditConfigPresenter.new(user, params, messages)
  end

  class Expense::ExpenseEditConfig::EditConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :currencies, :tds_slabs, :em_tax_tracking

    def init
      self.currencies = params[:currencies]
      self.em_tax_tracking = params[:em_tax_tracking]
      self.tds_slabs = params[:tds_slabs]
    end

  end
end