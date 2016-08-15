class User::Team::Review::NextReviewer < BaseOperation

  def self.call(obj)
    return nil if obj.blank?
    if obj.is_a?(CardLoadRequest)
      return next_reviewer(:card_load_request, obj)
    elsif obj.is_a?(Report)
      return next_reviewer(:report, obj)
    elsif obj.is_a?(Hash)
      user = obj[:user]
      return nil if user.blank?
      amount = obj[:amount]
      currency = obj[:currency]
      manager = User::Team::Approver.(user, type: :manager, amount: amount, currency_id: currency)
      return manager if manager.present?
      return User::Team::Approver.(user, type: :finance_manager, amount: amount, currency_id: currency)
    end
  end

  private
  def next_reviewer(sym, obj)
    user = obj.controlling_for_user
    user = obj.controlling_user if user.blank?
    user = obj.user if user.blank?
    arg_hash={}
    arg_hash[sym] = obj
    if obj.user.id == user.id
      arg_hash[:type] = :manager
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        arg_hash[:type] = :finance_manager
        return User::Team::Approver.(user, arg_hash)
      else
        return manager
      end
    end
    arg_hash[:type] = :manager
    if user.manager? and User::Team::IsApprover.(user, arg_hash)
      arg_hash[:type] = :approves_to
      manager = User::Team::Approver.(user, arg_hash)
      if manager.nil?
        return UserTeamService.new(obj.user).finance_manager(arg_hash)
      else
        return manager
      end
    end
    arg_hash[:type] = :finance_manager
    if user.finance_manager? and User::Team::IsApprover.(user, arg_hash)
      arg_hash[:type] = :approves_finance_to
      return User::Team::Approver.(user, arg_hash)
    end
    nil
  end

end