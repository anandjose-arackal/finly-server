class Masters::Users::Profile::Policy < ApplicationPolicy

  def update?
    owner?
  end

  def owner?
    record.user_id == user.id
  end

end