class ReceiptPolicy < ApplicationPolicy

  def initialize(user, receipt)
    @user = user
    @receipt = receipt
  end

  def create?
    check_personal_view
  end

  def destroy?
    check_personal_view
  end

  def index?
    check_personal_view
  end

  def expense_from_receipt?
    check_personal_view
  end

  def add_note?
    check_personal_view
  end
end