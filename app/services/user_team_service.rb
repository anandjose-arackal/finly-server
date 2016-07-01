class UserTeamService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user = user
  end

  def team(params={})
    load_retrieve params
    if @admin_view
      return nil unless user.admin?
      return user.company.users
    elsif @manager_view
      return nil unless user.manager?
      return UserManagerMapping.manager_team(@policy_id, self.user.id)
    elsif @finance_view
      return nil unless user.finance_manager?
      return UserManagerMapping.finance_team(@policy_id, self.user.id)
    end
    nil
  end

  # Retrieve service
  def mappings(params={})
    load_retrieve params
    @mappings.policy(@policy_id)
  end

  def manager(params={})
    load_retrieve params
    # todo validate if its better to go with rescue when manager is not assigned or have a seperate check which might result in 2 queries
    # return nil unless self.user.team_mapping.manager.present? # todo sample check
    # return @mapping.default.manager if @default
    @mappings.manager.policy(@policy_id).amount(@currency_id, @amount).manager rescue nil
  end

  def finance_manager(params={})
    load_retrieve params
    @mappings.finance_manager.policy(@policy_id).amount(@currency_id, @amount).finance_manager rescue nil
  end

  def approves_to(params={})
    return nil unless user.manager?
    load_retrieve params
    @mappings.approves_to.policy(@policy_id).amount(@currency_id, @amount).approves_to_user rescue nil
  end

  def approves_finance_to(params={})
    return nil unless user.finance_manager?
    load_retrieve params
    @mappings.approves_finance_to.policy(@policy_id).amount(@currency_id, @amount).approves_finance_to_user rescue nil
  end

  # Update service
  def update(params={})
    errors.clear
    load_update params
    if params[:manager_id].present?
      @mapping.update_attribute(manager_id: params[:manager_id])
    end
    if params[:finance_manager_id].present?
      @mapping.update_attribute(finance_manager_id: params[:finance_manager_id])
    end
    if params[:approves_to_user_id].present?
      @mapping.update_attribute(approves_to_user_id: params[:approves_to_user_id])
    end
    if params[:approves_finance_to_user_id].present?
      @mapping.update_attribute(approves_finance_to_user_id: params[:approves_finance_to_user_id])
    end
    errors << @mapping.errors.full_messages
    false if errors.present?
    true
  end

  # Create service
  def create(params={})
    errors.clear
    load_create params
    return false unless validate_create params
    mapping = @mappings.new(policy_id: @policy_id, greater_than_amount_attributes: {value: @amount, currency_id: @currency_id})
    if params[:manager_id].present?
      mapping.manager_id = params[:manager_id]
    end
    if params[:finance_manager_id].present?
      mapping.finance_manager_id = params[:finance_manager_id]
    end
    if params[:approves_to_user_id].present?
      mapping.approves_to_user_id = params[:approves_to_user_id]
    end
    if params[:approves_finance_to_user_id].present?
      mapping.approves_finance_to_user_id = params[:approves_finance_to_user_id]
    end
    return true if mapping.save
    errors << mapping.errors.full_messages
    false
  end

  # Destroy service
  def destroy(params={})
    load_update params
    if @mapping.default
      errors << 'Default user manager configuration cannot be deleted'
      return false
    end
    @mapping.destroy
  end

  # Reset all policy specific user mapping to default company mapping service
  def reset(params={})
    errors.clear
    load_update params
    if @policy_id.blank?
      errors << 'Non policy configuration cannot be reset'
      return false
    end
    unless @mapping.default
      errors.add << 'Non default configuration cannot be reset'
      return false
    end
    self.user.team_mapping.policy(@policy_id).delete_all
    self.user.team_mapping.policy(nil).each do |item|
      clone = item.dup
      clone.policy_id = @policy_id
      errors << clone.errors.full_messages unless clone.save
    end
    errors.blank?
  end

  def update_role(params={})
    errors.clear
    load_role_update params
    existing_roles = user.role_mapping.policy(@policy_id).map(&:user_role_id)
    new_roles = params[:user_role]
    new_roles = [new_roles] unless new_roles.is_a? Array
    roles_to_add = new_roles - existing_roles
    roles_to_remove = existing_roles - new_roles
    user.role_mapping.policy(@policy_id).role(roles_to_remove).delete_all
    roles_to_add.each do |role_id|
      user.role_mapping.create(policy_id: @policy_id, user_role_id: role_id)
    end
  end

  private
  def load_retrieve(params={})
    @admin_view = nil
    @manager_view = nil
    @finance_view = nil
    @mappings = nil
    @policy_id = nil
    @currency_id = nil
    @amount = nil

    @policy_id = params[:policy_id]
    @mappings = self.user.team_mapping
    @amount = params[:amount]
    @currency_id = params[:currency_id]
    view = params[:view]
    if view == 'admin'
      @admin_view = true
    elsif view == 'manager'
      @manager_view = true
    elsif view == 'finance'
      @finance_view = true
    end
  end

  def load_update(params={})
    @mapping = self.user.team_mapping.find_by(id: params[:team_mapping_id]) if params[:team_mapping_id].present?
  end

  def load_create(params={})
    @policy_id = params[:policy_id]
    @mappings = self.user.team_mapping
    @amount = params[:amount]
    @currency_id = params[:currency_id]
  end

  def validate_create(params={})
    errors.clear
    unless @amount.present? and @currency_id.present?
      errors << 'Greater than amount is not defined'
      false
    end
    mapping = @mappings.policy(@policy_id).exact_amount(@currency_id, @amount)
    return true unless mapping.present?
    if params[:manager_id].present?
      errors << 'Another manager is already configured for the given amount' if mapping.manager.present?
    end
    if params[:finance_manager_id].present?
      errors << 'Another finance manager is already configured for the given amount' if mapping.finance_manager.present?
    end
    if params[:approves_to_user_id].present?
      errors << 'Another manager is already configured for the given amount' if mapping.approves_to.present?
    end
    if params[:approves_finance_to_user_id].present?
      errors << 'Another manager is already configured for the given amount' if mapping.approves_finance_to.present?
    end
    errors.blank?
  end

  def load_role_update(params={})
    @policy_id = params[:policy_id]
    @roles = self.user.roles
  end

end