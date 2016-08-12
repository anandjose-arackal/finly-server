class ExpensePolicy < ApplicationPolicy

  def initialize(user, expense)
    @user = user
    @expense = expense
    @user_team_service = UserTeamService.new(@user)
  end

  def new?
    check_personal_view
  end

  # todo - will be updated once there's more clarity on admin view for expenses
  def index?
    check_personal_view
  end

  def show?
    return false unless check_personal_view
    # check if this user owns the particular expense being edited
    unless @expense.user.id == @user.id
      return false
    end
    true
  end

  def update?
    return false unless check_personal_view
    # check if this user owns the particular expense being edited
    unless @expense.user.id == @user.id
      return false
    end
    true
  end

  # can only be destroyed by the owner
  def destroy?
    return false unless check_personal_view
    # check if this user owns the particular expense being edited
    unless @expense.user.id == @user.id
      return false
    end
    true
  end

  def create?
    check_personal_view
  end

  def add_receipt?
    # check that it's personal view
    return false unless check_personal_view
    # check if this user owns the particular expense being edited
    unless @expense.user.id == @user.id
      return false
    end
    true
  end

  def unreported?
    check_personal_view
  end

end