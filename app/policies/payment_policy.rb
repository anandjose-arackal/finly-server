class PaymentPolicy < ApplicationPolicy

  def initialize(user, payment)
    @user = user
    @payment = payment
  end

  def index?
    if @user.admin? and check_admin_view
      return true
    elsif @user.finance_manager? and check_finance_view
      return true
    else
      return false
    end
  end

  def add_payment?
    if @user.admin? and check_admin_view
      return true
    elsif @user.finance_manager? and check_finance_view
      return true
    else
      return false
    end
  end

  def show?

  end

end