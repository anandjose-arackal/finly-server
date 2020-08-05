class Masters::Schema::Policy < ApplicationPolicy

  def index?
    user.admin?("vp")
  end

  def show?
    user.admin?("vp")
  end

end