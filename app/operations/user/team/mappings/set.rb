class User::Team::Mappings::Set < User::Team::Mappings::Base
  attr_accessor :updating_mapping

  def pre_validate
    super
    unless params[:user_manager_mapping].present?
      errors << 'Nothing to update'
    end
  end

  def pre_authorize
    if user.company_admin?
      self.updating_user = user.company.users.with_id(params[:user_id]).first rescue nil
    elsif user.policy_admin?
      if params[:user_manager_mapping].present?
        admin_policy_id = user.admin_policies.pluck(:id)
        params[:user_manager_mapping].each do |mapping|
          unless admin_policy_id.include?(mapping[:mapping_id])
            errors << 'You do not have the permission to make the following update'
            raise_unauthorized_exception
          end
        end
      end
    end
    self.updating_user = self.policy.users.with_id(params[:user_id]).first rescue nil
  end

  def init
    self.mappings = updating_user.team_mapping
    self.updating_mapping = params[:user_manager_mapping]
  end

  def process
    self.updating_mapping.each do |map|
      id = map[:mapping_id]
      updated_params = map[:mapping]
      if id.present?
        updating_map = self.mapping.with_id(id).first rescue nil
        if updating_map.blank?
          errors << 'Error updating configuration'
          return
        end
        if updated_params.present?
          updating_map.update_attributes(updated_params)
        else
          # Default mapping cannot be destroyed
          if updating_map.default
            updating_map.update_attributes(manager_id: nil, finance_manager_id: nil, approves_to_id: nil, approves_finance_to_id: nil)
          else
            updating_map.destroy
          end
        end
      else
        if updated_params.present?
          updated_params[:user_id] = updating_user.id
          self.mapping.create(updated_params)
        end
      end
    end
  end

end