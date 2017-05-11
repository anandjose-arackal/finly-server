class User::Group::Set < User::Base
  attr_accessor :selected_user, :group_config, :groups

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:id).blank? and params&.dig(:user_id).blank? and params&.dig(:user).blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.selected_user = params[:user]
    if self.selected_user.blank?
      id = (params[:id] or params[:user_id])
      if id == user.id
        self.selected_user = user
      else
        operation = User::Team::Index.new(user, params)
        result = operation.run
        if operation.success?
          self.selected_user = result.with_id(id).first rescue nil
        else
          messages[:error] = operation.messages[:error]
        end
      end
    end

    self.group_config = (params[:group_config]&.with_indifferent_access or {})
    self.groups = user.company.user_groups.include_items
  end

  def validate
    if self.groups.nil?
      add_message :error, 'Error loading configuration. Please try again'
    end
  end

  def process
    self.groups.each do |group|
      group_id = group.id
      group_item_id = group_config&.dig(group_id&.to_s)
      user_group_mapping = user.user_group_item_mappings.with_user(selected_user.id).with_group(group_id)&.first
      if group_item_id.blank?
        if user_group_mapping.present?
          # User Group Item has been set to None
          user_group_mapping.destroy
        end
      else
        if user_group_mapping.present?
          # User Group Mapping has been updated
          user_group_mapping.update(user_group_item_id: group_item_id)
        else
          # User Group Mapping has been created
          user.user_group_item_mappings.create user_group_item_id: group_item_id, group_id: group_id
        end
      end
    end
  end

end