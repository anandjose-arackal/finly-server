class UserTeamService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user = user
  end

  def team(role_id, params={})
    errors.clear
    unless user.present?
      errors << 'User not found'
      return false
    end
    unless role_id.present?
      errors << 'User role not defined'
      return false
    end
    indirect_associations = params[:indirect_associations]
    user_ids = []
    manager_association = nil
    approves_to_association = nil
    case role_id
      when UserRole.admin_id
        unless user.admin?
          errors << 'User is not an Admin'
          return false
        end
        return admin_team
      when UserRole.finance_manager_id
        unless user.finance_manager?
          errors << 'User is not a Finance Manager'
          return false
        end
        manager_association = :has_finance_manager
        approves_to_association = :has_approves_finance_to
      when UserRole.manager_id
        unless user.manager?
          errors << 'User is not a Manager'
          return false
        end
        manager_association = :has_manager
        approves_to_association = :has_approves_to
    end
    return nil if manager_association.blank? or approves_to_association.blank?
    user_ids += UserManagerMapping.send(manager_association, user.id).pluck(:id)
    approves_to_ids = UserManagerMapping.send(approves_to_association, user.id).pluck(:id)
    while indirect_associations and approves_to_ids.present?
      user_ids += UserManagerMapping.send(manager_association, approves_to_ids).pluck(:id)
      approves_to_ids = UserManagerMapping.send(approves_to_association, approves_to_ids).pluck(:id)
    end
    user_ids.uniq! if user_ids.present?
    if user_ids.present?
      return user.company.users.with_id(user_ids)
    end
    nil
  end

  # Can pass report or user object
  # Passing a report would check if the user is a manager for the report
  # Passing a user would check if the user is a direct manager for the given user object
  # If indirect_associations is set to true in params while passing user object,
  # it checks if the user is associated as a manager with the given user which includes chains of approvals
  def manager_for?(obj, params={})
    errors.clear
    managing_user = self.user
    if params[:user].present?
      managing_user = params[:user]
    end
    if obj.is_a?(Report)
      report = obj
      emp = report.user
      m = UserTeamService.new(emp).manager(report: report)
      while m.present?
        return true if m.id == managing_user.id
        m = UserTeamService.new(m).approves_to(report: report)
      end
    elsif obj.is_a?(CardLoadRequest)
      card_load_request = obj
      emp = report.user
      m = UserTeamService.new(emp).manager(card_load_request: card_load_request)
      while m.present?
        return true if m.id == managing_user.id
        m = UserTeamService.new(m).approves_to(card_load_request: card_load_request)
      end
    elsif obj.is_a?(User)
      for_user = obj
      emp = UserManagerMapping.has_manager(managing_user.id).with_user(for_user.id)
      if emp.present?
        return true
      end
      if params[:indirect_associations]
        approves_to_ids = UserManagerMapping.has_approves_to(managing_user.id).pluck(:id)
        while approves_to_ids.present?
          emp = UserManagerMapping.has_manager(approves_to_ids).with_user(for_user.id)
          if emp.present?
            return true
          end
          approves_to_ids = UserManagerMapping.has_approves_to(approves_to_ids).pluck(:id)
        end
      end
    else
      errors << 'Invalid Params'
      return false
    end
    false
  end

  # Can pass report or user object
  # Passing a report would check if the user is a finance manager for the report
  # Passing a user would check if the user is a direct finance manager for the given user object
  # If indirect_associations is set to true in params while passing user object,
  # it checks if the user is associated as a finance manager with the given user which includes chains of approvals
  def finance_manager_for?(obj, params={})
    errors.clear
    managing_user = self.user
    if params[:user].present?
      managing_user = params[:user]
    end
    if obj.is_a?(Report)
      report = obj
      emp = report.user
      m = UserTeamService.new(emp).finance_manager(report)
      while m.present?
        return true if m.id == managing_user.id
        m = UserTeamService.new(m).approves_finance_to(report)
      end
    elsif obj.is_a?(CardLoadRequest)
      card_load_request = obj
      emp = card_load_request.user
      m = UserTeamService.new(emp).finance_manager(card_load_request)
      while m.present?
        return true if m.id == managing_user.id
        m = UserTeamService.new(m).approves_finance_to(card_load_request)
      end
    elsif obj.is_a?(User)
      for_user = obj
      emp = UserManagerMapping.has_finance_manager(managing_user.id).with_user(for_user.id)
      if emp.present?
        return true
      end
      if params[:indirect_associations]
        approves_to_ids = UserManagerMapping.has_approves_finance_to(managing_user.id).pluck(:id)
        while approves_to_ids.present?
          emp = UserManagerMapping.has_finance_manager(approves_to_ids).with_user(for_user.id)
          if emp.present?
            return true
          end
          approves_to_ids = UserManagerMapping.has_approves_finance_to(approves_to_ids).pluck(:id)
        end
      end
    else
      errors << 'Invalid Params'
      return false
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
    obj = @mappings.manager.policy(@policy_id).amount(@currency_id, @amount).first.manager rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def finance_manager(params={})
    load_retrieve params
    obj = @mappings.finance_manager.policy(@policy_id).amount(@currency_id, @amount).first.finance_manager rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def approves_to(params={})
    return nil unless user.manager?
    load_retrieve params
    @policy_id = nil unless @policy_id.blank? or PolicyRetrievalService.new(user).list.with_id(@policy_id).present?
    obj = @mappings.approves_to.policy(@policy_id).amount(@currency_id, @amount).first.approves_to_user rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  def approves_finance_to(params={})
    return nil unless user.finance_manager?
    load_retrieve params
    @policy_id = nil unless @policy_id.blank? or PolicyRetrievalService.new(user).list.with_id(@policy_id).present?
    obj = @mappings.approves_finance_to.policy(@policy_id).amount(@currency_id, @amount).first.approves_finance_to_user rescue nil
    return nil unless obj.present? and obj.is_a?(User)
    obj
  end

  # Update service
  def update(params={})
    errors.clear
    load_update params
    # updating greater than amount for non-default if it needs to be updated
    if not @mapping.default and not params['amount'].blank? and params['amount'] != @mapping.greater_than_amount_value and
        params['currency_id'] != @mapping.greater_than_amount_currency_id
      greater_than_amount = Amount.create(value: params['amount'], currency_id: params['currency_id'])
      @mapping.update_attributes(greater_than_amount_id: greater_than_amount.id)
    end
    manager_id = params[:manager_id] || params['manager_id']
    finance_manager_id = params[:finance_manager_id] || params['finance_manager_id']
    approves_to_user_id = params[:approves_to_user_id] || params['approves_to_user_id']
    approves_finance_to_user_id = params[:approves_finance_to_user_id] || params['approves_finance_to_user_id']
    # if amount is left empty, remove the conditional manager params
    if params['amount'] and params['amount'].empty? and not @mapping.default
      manager_id = finance_manager_id = approves_to_user_id = approves_finance_to_user_id = nil
    end
    if @mapping.update_attributes(manager_id: manager_id,
                                  finance_manager_id: finance_manager_id,
                                  approves_to_user_id: approves_to_user_id,
                                  approves_finance_to_user_id: approves_finance_to_user_id)
      return true
    else
      errors << @mapping.errors.full_messages
      return false
    end
  end

  # Create service
  def create(params={})
    errors.clear
    load_create params
    return false unless validate_create params
    mapping = @mappings.new(policy_id: @policy_id, greater_than_amount_attributes: {value: @amount, currency_id: @currency_id})
    if params[:manager_id].present? || params['manager_id'].present?
      mapping.manager_id = params[:manager_id] || params['manager_id']
    end
    if params[:finance_manager_id].present? || params['finance_manager_id'].present?
      mapping.finance_manager_id = params[:finance_manager_id] || params['finance_manager_id']
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

  # takes as input all the roles the user needs to be added to
  def update_role(params={})
    errors.clear
    load_role_update params
    existing_role_ids = user.role_mapping.map(&:user_role_id)
    new_role_ids = params[:user_role_id]
    new_role_ids = [new_role_ids] unless new_role_ids.is_a?(Array)
    roles_to_add = new_role_ids - existing_role_ids
    roles_to_add.each do |role_id|
      unless user.role_mapping.create(user_role_id: role_id)
        errors << user.role_mapping.errors.full_messages
        return false
      end
    end
    true
  end

  def remove_role(params={})
    errors.clear
    load_role_update params
    @user_team_service = UserTeamService.new(user)
    roles_to_remove = params[:user_role_id]
    roles_to_remove.each do |role|
      if @user_team_service.team(role)
        unless @user_team_service.team(role).empty?
          errors << "#{self.user.name} has other team members under him. "
          return false
        end
      end
    end
    unless user.role_mapping.role(roles_to_remove).destroy_all
      errors << user.role_mapping.errors.full_messages
      return false
    end
    true
  end

  private
  def load_retrieve(params={})
    @admin_view = nil
    @manager_view = nil
    @finance_view = nil
    @currency_id = params[:currency_id]
    @amount = params[:amount]
    @mappings = self.user.team_mapping.with_details
    if params[:policy_id]
      @policy_id = params[:policy_id]
    elsif params[:policy].present?
      policy = params[:policy]
      @policy_id = policy.id
      if params[:currency_id].present?
        @currency_id = params[:currency_id]
      else
        @currency_id = policy.configuration.report_currency
      end
      @amount = params[:amount]
    elsif params[:report].present?
      report = params[:report]
      if report.policy_id.present? and user.policies.with_id(report.policy_id).present?
        @policy_id = report.policy_id
      else
        @policy_id = nil
      end
      rds = ReportDetailService.new(report)
      @currency_id = rds.currency
      @amount = rds.total_amount
    elsif params[:card_load_request].present?
      card_load_request = params[:card_load_request]
      if card_load_request.policy_id.present? and user.policies.with_id(card_load_request.policy_id).present?
        @policy_id = card_load_request.policy_id
      else
        @policy_id = nil
      end
      @currency_id = card_load_request.amount.currency
      @amount = card_load_request.amount.value
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
    @amount = params[:amount] || params['amount']
    @currency_id = params[:currency_id] || params['currency_id']
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

  def admin_team
    errors.clear
    if user.company_admin?
      return user.company.users
    elsif user.policy_admin?
      users = user.company.users
      policies = user.admin_policies.pluck(:id)
      if policies.present?
        return users.with_id(PolicyUserMapping.with_policy(policies).pluck(:user_id))
      end
    end
    errors << 'User is not an admin'
    false
  end

end