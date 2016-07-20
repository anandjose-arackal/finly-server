class ExpensePolicy < ApplicationPolicy

  def initialize(user, expense, params)
    @user = user
    @expense = expense
    @params = params
    @user_team_service = UserTeamService.new(@user)
  end

  # def create?
  #   if @user.finance_manager? or @user.auditor?
  #     return false
  #   end
  #   return true
  # end

  def update?
    if @user.employee?
      if @user.expenses.include?(@expense)
        return true
      end
      return false
    elsif @user.manager?
      # load users from team
      user_ids = @user_team_service.team.pluck(:user_id)
      expenses = Expense.where(user_id: user_ids)
      if expenses.include?(@expense)
        return true
      end
      return false
    elsif @user.admin?
      user_ids = @user.company.users.pluck(:id)
      expenses = Expense.where(user_id: user_ids)
      if expenses.include?(@expense)
        return true
      end
      return false
    else
      # do nothing
    end
  end

  # can only be destroyed by the owner
  def destroy?
    if @user.employee?
      if @user.expenses.include?(@expense)
        return true
      end
    end
    false
  end


end