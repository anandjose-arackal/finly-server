class PaymentPolicy < ApplicationPolicy

  def initialize(user, viewed_user)
    @user = user
    @viewed_user = viewed_user
  end

  def index?
    if check_admin_view || check_finance_view
      return true
    else
      return false
    end
  end

  def add_payment?
    if check_admin_view || check_finance_view
      return true
    else
      return false
    end
  end

  def show?
    if check_personal_view
      if @user.id == @viewed_user.id
        return true
      else
        return false
      end
    end
    check_admin_view or check_finance_view
  end

end