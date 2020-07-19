class Admin::Masters::Macros::Jobs::Policy < ApplicationPolicy

  def show?
    true
  end

  def create?
    true
  end

end