class User::Team::Review::UserRole < BaseOperation

  def self.call(user, obj)
    return nil unless obj.present? and user.present?
    obj_type = nil
    if obj.is_a?(MoneyRequest)
      obj_type = :money_request
    elsif obj.is_a?(Report)
      obj_type = :report
    end
    return nil unless obj_type.present?

    if user.id == obj.user.id
      return UserRole.id_for(:employee)
    else
      param = {}
      param[obj_type] = obj
      param[:type] = :manager
      if user.manager? and User::Team::IsApprover.(user, param)
        return UserRole.manager_id
      end
      param[:type] = :finance_manager
      if user.finance_manager? and User::Team::IsApprover.(user, param)
        return UserRole.finance_manager_id
      end
    end
  end

end