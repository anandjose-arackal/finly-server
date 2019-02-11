class User::DelegateMappings::Base < BaseOperation
  attr_accessor :associated_users

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if actual_current_user.present?
      unless actual_current_user.delegated_for_users.present?
        add_message :error, 'You are not delegated for any user'
        return
        unless actual_current_user.delegation_enabled
          add_message :error, 'Delegation is not enabled for you'
          return
        end
      end
    end
    if actual_current_user.blank?
      unless user.delegation_enabled
        add_message :error, 'Delegation is not enabled for you'
        return
      end
    end
  end
end