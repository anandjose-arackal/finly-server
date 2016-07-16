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

  def manager_for?(report)
    emp = report.user
    return false if report.blank?
    rds = ReportDetailService.new(report)
    policy = report.policy
    policy = rds.policy unless policy.blank?
    m = UserTeamService.new(emp).manager(report: report)
    while m.present?
      return true if m.id == self.user.id
      m = UserTeamService.new(m).approves_to(report: report)
    end
    false
  end

  def finance_manager_for?(report)
    emp = report.user
    return false if report.blank?
    rds = ReportDetailService.new(report)
    policy = report.policy
    policy = rds.policy unless policy.blank?
    m = UserTeamService.new(emp).finance_manager(policy: policy, currency: rds.currency, amount: rds.total_amount)
    while m.present?
      return true if m.id == self.user.id
      m = UserTeamService.new(m).approves_finance_to(policy: policy, currency: rds.currency, amount: rds.total_amount)
    end
    false
  end

  def final_finance_manager(report)
    emp = report.user
    return false if report.blank?
    rds = ReportDetailService.new(report)
    policy = report.policy
    policy = rds.policy unless policy.blank?
    m = UserTeamService.new(emp).finance_manager(policy: policy, currency: rds.currency, amount: rds.total_amount)
    while m.present?
      m = UserTeamService.new(m).approves_finance_to(policy: policy, currency: rds.currency, amount: rds.total_amount)
    end
    m
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
    obj = @mappings.manager.policy(@policy_id).amount(@currency_id, @amount).manager rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def finance_manager(params={})
    load_retrieve params
    obj = @mappings.finance_manager.policy(@policy_id).amount(@currency_id, @amount).finance_manager rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def approves_to(params={})
    return nil unless user.manager?
    load_retrieve params
    @policy_id = nil unless @policy_id.blank? or PolicyRetrievalService.new.list(user).with_id(@policy_id).present?
    obj = @mappings.approves_to.policy(@policy_id).amount(@currency_id, @amount).approves_to_user rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def approves_finance_to(params={})
    return nil unless user.finance_manager?
    load_retrieve params
    @policy_id = nil unless @policy_id.blank? or PolicyRetrievalService.new.list(user).with_id(@policy_id).present?
    obj = @mappings.approves_finance_to.policy(@policy_id).amount(@currency_id, @amount).approves_finance_to_user rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
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
    self.user.team_mapping.policy(@policy_id).destroy_all
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
    user.role_mapping.policy(@policy_id).role(roles_to_remove).destroy_all
    roles_to_add.each do |role_id|
      user.role_mapping.create(policy_id: @policy_id, user_role_id: role_id)
    end
  end

  private
  def load_retrieve(params={})
    @admin_view = nil
    @manager_view = nil
    @finance_view = nil
    @mappings = self.user.team_mapping
    if params[:policy_id]
      @policy_id = params[:policy_id]
      @currency_id = params[:currency_id]
      @amount = params[:amount]
    elsif params[:policy].present?
      policy = params[:policy]
      @policy_id = policy.id
      if params[:currenc_id].present?
        @currency_id = params[:currency_id]
      else
        @currency_id = policy.configuration.default_currency
      end
      @amount = params[:amount]
    elsif params[:report.present?]
      report = params[:report]
      rds = ReportDetailService.new(report)
      policy = rds.policy
      @policy_id = policy.id
      @currency_id = rds.currency
      @amount = rds.total_amount
    end

    load_view params


    # @policy_version_timestamp = params[:policy_version]
    # if @policy_id.blank? and params[:policy] and params[:policy].present? and params[:policy].is_a?(Policy)
    #   @policy_id = params[:policy].id
    # end
    # if @policy_id.blank? and params[:report] and params[:report].present? and params[:report].is_a?(Report)
    #   @policy_id = params[:report].policy_id
    #   # todo when report is created add submitted at field for calculating version
    #   # @policy_version_timestamp = params[:report].submitted_at
    # end


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