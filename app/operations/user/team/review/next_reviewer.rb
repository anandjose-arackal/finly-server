class User::Team::Review::NextReviewer < BaseOperation

  def self.call(obj)
    return nil if obj.blank?
    if obj.is_a?(CardLoadRequest)
      return to_user(:card_load_request, obj)
    elsif obj.is_a?(Report)
      return to_user(:report, obj)
    elsif obj.is_a?(Hash)
      user = obj[:user]
      return nil if user.blank?
      amount = obj[:amount]
      currency = obj[:currency]
      uts = UserTeamService.new(user)
      manager = uts.manager(amount: amount, currency_id: currency)
      manager = User::Team::Approver.(user, type: :manager, amount: amount, currency_id: currency)
      return manager if manager.present?
      return uts.finance_manager(amount: amount, currency_id: currency)
    end
  end

  private
  def next_reviewer(sym, obj)
    user = obj.controlling_for_user
    user = obj.controlling_user if user.blank?
    user = obj.user if user.blank?
    uts = UserTeamService.new(user)
    arg_hash={}
    arg_hash[sym] = obj
    if obj.user.id == user.id
      manager = uts.manager arg_hash
      if manager.nil?
        return uts.finance_manager arg_hash
      else
        return manager
      end
    end
    if user.manager? and uts.manager_for?(obj, user: user)
      manager = uts.approves_to(arg_hash)
      if manager.nil?
        return UserTeamService.new(obj.user).finance_manager(arg_hash)
      else
        return manager
      end
    end
    if user.finance_manager? and uts.finance_manager_for?(obj, user: user)
      return uts.approves_finance_to arg_hash
    end
    nil
  end

end