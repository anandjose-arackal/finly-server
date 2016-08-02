class ReceiptPolicy < ApplicationPolicy

  def initialize(user, receipt)
    @user = user
    @receipt = receipt
  end

  def create?
    return unless check_personal_view
  end

  def destroy?
    return unless check_personal_view
  end

  def index?
    return unless check_personal_view
  end

  def expense_from_receipt?
    return unless check_personal_view
  end

  def add_note?
    return unless check_personal_view
  end
end