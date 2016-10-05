class User::Team::Mappings::Set < User::Team::Mappings::Base
  attr_accessor :updating_mapping, :policy, :updating_records, :records_marked_for_destroy

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    super
    unless params[:user_manager_mapping].present?
      messages[:error] << 'Nothing to update'
    end
  end

  def pre_authorize
    user_id = (params[:id] or params[:user_id])
    self.updating_user = user.company.users.find_by(id: user_id)
    # if user.company_admin?
    #   self.updating_user = user.company.users.with_id(user_id).first rescue nil
    # elsif user.policy_admin?
    #   if params[:user_manager_mapping].present?
    #     admin_policy_id = user.admin_policies.pluck(:id)
    #     params[:user_manager_mapping].each do |key, mapping|
    #       unless admin_policy_id.include?(mapping[:mapping_id])
    #         messages[:error] << 'You do not have the permission to make the following update'
    #         raise_unauthorized_exception
    #       end
    #     end
    #   end
    #   team = User::Team::Index.(user, view: 'admin')
    #   self.updating_user = team.with_id(user_id).first rescue nil
    # # elsif user.manager?
    # #   team = User::Team::Index.(user, view: 'manager')
    # #   self.updating_user = team.with_id(user_id).first rescue nil
    # # elsif user.finance_manager?
    # #   team = User::Team::Index.(user, view: 'finance_manager')
    # #   self.updating_user = team.with_id(user_id).first rescue nil
    # end
    # # unless updating_user
    # #   messages[:error] << "Cannot find user to update mapping."
    # # end
  end

  def init
    self.mappings = updating_user.team_mapping
    self.updating_mapping = params[:user_manager_mapping]
    self.updating_records = []
    self.records_marked_for_destroy = []

    currency_id = Currency.first.id
    self.updating_mapping.each do |key, map|
      # to remove all empty values
      # Formatter.remove_blanks map
      next if map.blank?
      id = map[:mapping_id]
      updated_params = map[:mapping]
      # this is only when the policy user mappings are being updated
      updated_params[:policy_id] = params[:policy_id] if params[:policy_id]
      if id.present?
        updating_map = self.mappings.with_id(id).first rescue nil
        if updating_map.blank?
          messages[:error] << 'Error updating configuration'
          return
        end
        if updated_params.present?
          # Remove if greater than amount ID has to be passed from the client
          if updated_params[:greater_than_amount_attributes].present? and updating_map.greater_than_amount_id.present?
            updated_params[:greater_than_amount_attributes][:id] = updating_map.greater_than_amount_id
          end
          updating_map.assign_attributes(update_params(updated_params))
          self.updating_records << updating_map
        else
          # Default mapping cannot be destroyed
          if updating_map.default
            updating_map.assign_attributes(manager_id: nil, finance_manager_id: nil, approves_to_id: nil, approves_finance_to_id: nil)
            self.updating_records << updating_map
          else
            self.records_marked_for_destroy << updating_map
          end
        end
      else
        # If ID is not present, create new user mapping
        if updated_params.present?
          updated_params[:user_id] = updating_user.id
          updated_params['greater_than_amount_attributes']['currency_id'] = currency_id
          self.updating_records << self.mappings.build(update_params(updated_params))
        end
      end
    end
  end

  def validate
    updating_records.compact!
    self.updating_records.each do |record|
      self.updating_records.each do |record2|
        next if record == record2
        next unless record.policy_id == record2.policy_id
        [record, record2].each do |item|
          if not item.default and (item.greater_than_amount.blank? or item.greater_than_amount.value.blank? or item.greater_than_amount.value <= 0)
            messages[:error] << 'Invalid amount value. Amount has to be greater than 0'
            return
          end
        end
        {manager: :manager_id, finance_manager: :finance_manager_id, approves_to: :approves_to_id, approves_finance_to: :approves_finance_to_id}.each do |key, item|
          if record.send(item).present? and record2.send(item).present?
            if record.default and record2.default
              messages[:error] << 'Error assigning configuration'
              return
            elsif record.default or record2.default
              next
            elsif record.greater_than_amount.blank? or record2.greater_than_amount.blank? or record.greater_than_amount.value <= 0 or record2.greater_than_amount.value <= 0
              messages[:error] << 'Error setting configuration. Amount value cannot be less than or equal to 0'
              return
            elsif record.greater_than_amount.value == record2.greater_than_amount.value and not self.records_marked_for_destroy.include?(record) and not self.records_marked_for_destroy.include?(record2)
              messages[:error] << 'You cannot assign two configurations with the same amount value'
              return
            end
          end
        end
      end
    end
  end

  def process
    self.updating_records.each do |record|
      record.save
    end
    self.records_marked_for_destroy.each do |record|
      record.destroy
    end
  end

  def post_process
    messages[:success] << 'Configuration Updated!'
  end

  private
  def update_params(params)
    params.permit(:policy_id, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :user_id, greater_than_amount_attributes: [:id, :value, :currency_id])
  end

end