class Policy::Mappings::Set < Policy::Base
  attr_accessor :updating_mapping, :policy, :policy_id, :updating_user, :mappings,


  def pre_validate
    if user.blank? or (params[:user_id].blank? and params[:id].blank?)
      add_message :error, 'User not found'
    end
    unless params[:user_manager_mapping].present?
      add_message :error, 'Nothing to update'
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
            add_message :error, 'You do not have the permission to make the following update'
            raise_unauthorized_exception
          end
        end
      end
      team = User::Team::Index.(user, view: 'admin')
      self.updating_user = team.with_id(user_id).first rescue nil
      # elsif user.manager?
      #   team = User::Team::Index.(user, view: 'manager')
      #   self.updating_user = team.with_id(user_id).first rescue nil
      # elsif user.finance_manager?
      #   team = User::Team::Index.(user, view: 'finance_manager')
      #   self.updating_user = team.with_id(user_id).first rescue nil
    end
    # unless updating_user
    #   add_message :error, "Cannot find user to update mapping."
    # end
  end

  def init
    self.mappings = updating_user.team_mapping
    self.updating_mapping = params[:user_manager_mapping]
    self.policy_id = params[:policy_id]
    self.policy = Policy::Index.(user, view: params[:view]).policies.find_by(id: params[:policy_id])
  end

  def validate
    currency_id = Currency.first.id
    self.updating_mapping.each do |key, map|
      # Formatter.remove_blanks map
      next if map.blank? or map[:mapping].blank?
      mapping_id = map[:mapping_id]
      if mapping_id.present?
        updating_map = self.mappings.with_id(mapping_id).first rescue nil
        next if updating_map.present? and updating_map.default
      end
      updated_params = map[:mapping]
      amount_value = updated_params['greater_than_amount_attributes']['value'] rescue nil
      # mind = blown - this was causing the same amount multiple times error
      if amount_value.blank? or amount_value.to_f <= 0
        add_message :error, 'Error setting configuration. Amount value cannot be 0'
        next
      end
      if updated_params[:manager_id].blank? and updated_params[:finance_manager_id].blank? and updated_params[:approves_to_id].blank? and updated_params[:approves_finance_to_id].blank?
        add_message :error, 'Error setting configuration. Manager cannot be blank'
      end
      v = self.mappings.policy(policy_id).exact_amount(currency_id, amount_value)
      v = v.without_id(mapping_id) if mapping_id.present?
      present= false
      {manager: :manager_id, finance_manager: :finance_manager_id, approves_to: :approves_to_id, approves_finance_to: :approves_finance_to_id}.each do |key, item|
        if updated_params[item].present? and v.send(key).present?
          present = true
        end
      end
      if present
        add_message :error, 'A configuration for the given amount has already been defined!'
        break
      end
    end
  end



  def process
    self.updating_mapping.each do |key, map|
      # to remove all empty values
      # Formatter.remove_blanks map
      next if map.blank?
      id = map[:mapping_id]
      updated_params = map[:mapping]
      # this is only when the policy user mappings are being updated
      updated_params[:policy_id] = policy_id
      if id.present?
        updating_map = self.mappings.with_id(id).first rescue nil
        if updating_map.blank?
          add_message :error, 'Error updating configuration'
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
          updated_params['greater_than_amount_attributes']['currency_id'] = 1
          self.mappings.create(update_params(updated_params))
        end
      end
    end
  end


  def success
    Policy::Base::PolicyPresenter.new(user, {policy: policy}, messages)
  end

  def post_process
    messages[:success] << 'Updated!'
  end

  private
  def update_params(params)
    params.permit(:policy_id, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :user_id, greater_than_amount_attributes: [:id, :value, :currency_id])
  end

end