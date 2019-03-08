class User::Team::Review::RejectToUsersList < BaseOperation

  def self.call(obj, user=nil)
    return nil unless obj.is_a?(MoneyRequest) or obj.is_a?(Report)
    return nil unless obj.processing?
    if obj.is_a?(MoneyRequest)
      MoneyRequests::AssociatedUsers.(self.user, money_request: self.obj, user_before: user)
    elsif obj.is_a?(Report)
      Reports::AssociatedUsers.(self.user, report: self.obj, user_before: user)
    end
  end

end