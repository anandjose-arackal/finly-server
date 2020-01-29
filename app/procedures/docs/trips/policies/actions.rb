class Docs::Trips::Policies::Actions < ApplicationPolicy

  def show?
    true
  end

  def create?
    true
  end

end