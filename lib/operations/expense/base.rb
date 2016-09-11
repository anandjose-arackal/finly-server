class Expense::Base < BaseOperation
  attr_accessor :expense

  def authorized_user_types
    [:employee, :manager, :admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      errors << 'User not found'
    end
  end

  def init
    id = (params[:expense_id] or params[:id])
    self.expense = Expense::Index.(user, params).expenses.with_id(id).first rescue nil
  end

  def success
    Expense::Base::Presenter.new(user, expense: self.expense)
  end

  class Expense::Base::Presenter < BaseOperation::BasePresenter
    attr_accessor :expense

    def initialize(user, params)
      super(user, params)
      self.expense = params[:expense]
    end
  end


end