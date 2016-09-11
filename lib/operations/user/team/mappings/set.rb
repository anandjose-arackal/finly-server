class User::Team::Mappings::Set < User::Team::Mappings::Base
  attr_accessor :updating_mapping

  def pre_validate
    super
    unless params[:user_manager_mapping].present?
      errors << 'Nothing to update'
    end
  end

  def pre_authorize
    user_id = (params[:id] or params[:user_id])
    if user.company_admin?
      self.updating_user = user.company.users.with_id(user_id).first rescue nil
    elsif user.policy_admin?
      if params[:user_manager_mapping].present?
        admin_policy_id = user.admin_policies.pluck(:id)
        params[:user_manager_mapping].each do |key, mapping|
          unless admin_policy_id.include?(mapping[:mapping_id])
            errors << 'You do not have the permission to make the following update'
            raise_unauthorized_exception
          end
        end
      end
      team = User::Team::Index.(user, view: 'admin')
      self.updating_user = team.with_id(user_id).first rescue nil
    end
  end

  def init
    self.mappings = updating_user.team_mapping
    self.updating_mapping = params[:user_manager_mapping]
  end

  def process
    self.updating_mapping.each do |key, map|
      # to remove all empty values
      Formatter.remove_blanks map
      next if map.blank?
      id = map[:mapping_id]
      updated_params = map[:mapping]
      if id.present?
        updating_map = self.mappings.with_id(id).first rescue nil
        if updating_map.blank?
          errors << 'Error updating configuration'
          return
        end
        if updated_params.present?
          # Remove if greater than amount ID has to be passed from the client
          if updated_params[:greater_than_amount_attributes].present? and updating_map.greater_than_amount_id.present?
            updated_params[:greater_than_amount_attributes][:id] = updating_map.greater_than_amount_id
          end
          updating_map.update_attributes(update_params(updated_params))
        else
          # Default mapping cannot be destroyed
          if updating_map.default
            updating_map.update_attributes(manager_id: nil, finance_manager_id: nil, approves_to_id: nil, approves_finance_to_id: nil)
          else
            updating_map.destroy
          end
        end
      else
        # If ID is not present, create new user mapping
        if updated_params.present?
          updated_params[:user_id] = updating_user.id
          updated_params["greater_than_amount_attributes"]["currency_id"] = 1
          self.mappings.create(update_params(updated_params))
        end
      end
    end
  end

  def success
    true
  end

  private
  def update_params(params)
    params.permit(:manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :user_id, greater_than_amount_attributes: [:id, :value, :currency_id])
  end

end