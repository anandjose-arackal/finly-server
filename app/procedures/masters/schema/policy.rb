class Masters::Schema::Policy < ApplicationPolicy

  def index?
    user.admin?("vp")
  end

end