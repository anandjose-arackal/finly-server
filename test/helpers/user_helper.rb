module UserHelper

  def generate_user(options={})
    User.find(17)
  end

  def unlock_user(user)
    user.update(locked_at: nil)
  end

  def lock_user(user, time = DateTime.now)
    user.update(locked_at: time)
  end

end