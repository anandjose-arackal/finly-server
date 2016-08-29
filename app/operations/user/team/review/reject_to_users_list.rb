class User::Team::Review::RejectToUsersList < BaseOperation

  def self.call(obj, user=nil)
    return nil unless obj.is_a?(CardLoadRequest) or obj.is_a?(Report)
    return nil unless obj.processing?
    obj.associated_users(user)
  end

end