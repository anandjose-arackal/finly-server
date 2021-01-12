class Companies::Policy < ApplicationPolicy

  # TODO: update this to check for org admin role

  def create?
    true 
  end

  def update?
    true 
  end

  def index?
    true 
  end

  def show?
    true 
  end

end