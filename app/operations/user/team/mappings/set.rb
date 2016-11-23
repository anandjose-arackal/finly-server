class User::Team::Mappings::Set < User::Team::Mappings::Base
  attr_accessor :updating_mapping, :policy, :updating_records, :records_marked_for_destroy,
    :updating_policy_config, :updating_policy_records

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    super
    if params[:id].blank? and params[:user_id].blank?
      add_message :error, 'User not found'
      return
    end
    unless params[:user_manager_mapping].present?
      messages[:error] << 'Nothing to update'
    end
  end

  def init
    user_id = (params[:id] or params[:user_id])
    self.updating_user = user.company.users.with_id(id: user_id).first rescue nil
    return if self.updating_user.blank?
    self.mappings = updating_user.team_mapping
    self.updating_policy_config = params[:user_policy_config]
    self.updating_mapping = params[:user_manager_mapping]
    load_updating_records
    load_updating_policy_config
  end

  def validate
    # Validate updating records to ensure duplicate amounts  don't exist
    self.updating_records.compact!
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

    # Validate policy admin config being updated
    self.updating_policy_records.each do |record|
      unless record.valid?
        add_message :error, record.errors.full_messages
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
    self.updating_policy_records.each do |record|
      record.save
    end
  end

  def post_process
    messages[:success] << 'Configuration Updated!'
  end

  private
  def update_params(params)
    params.permit(:policy_id, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :user_id, greater_than_amount_attributes: [:id, :value, :currency_id])
  end

  def load_updating_records
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

  def load_updating_policy_config
    self.updating_policy_records = []
    policy_user_mappings = selected_user.policy_user_mappings
    self.updating_policy_config.each do |map|
      policy_id = map[:policy_id]
      admin = StringUtils.to_bool((map[:admin] or false))
      policy_mapping = policy_user_mappings.with_policy(policy_id).first rescue nil if policy_id.present?
      if policy_id.blank? or policy_mapping.blank?
        add_message :error, 'Error updating configuration'
        return
      end
      policy_mapping.assign_attributes(admin: admin)
      self.updating_policy_records << policy_mapping
    end
  end

end
