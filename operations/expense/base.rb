class Expense::Base < BaseOperation
  attr_accessor :expense

  def authorized_user_types
    [:employee]
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

  def retrieve
    if is_success?
      Expense::Base::Presenter.new(user, expense: self.expense)
    else
      false
    end
  end

  class Expense::Base::Presenter < BaseOperation::BasePresenter
    attr_accessor :expense

    def initialize(user, params)
      super(user, params)
      self.expense = params[:expense]
    end
  end


end