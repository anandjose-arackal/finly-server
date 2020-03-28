class Docs::P2P::Invoices::Po::Policy < ApplicationPolicy

  def create?
    true
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def show?
    owner?
  end

  def owner?
    record.user == user
  end

end