class PaymentPolicy < ApplicationPolicy

  def initialize(user, payment)
    @user = user
    @payment = payment
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

  end

end