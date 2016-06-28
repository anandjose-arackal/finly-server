class UserTeamService
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def team(params={})
    load params
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

  def manager(params={})
    load params
    # todo validate if its better to go with rescue when manager is not assigned or have a seperate check which might result in 2 queries
    # return nil unless self.user.team_mapping.manager.present? # todo sample check
    # return @mapping.default.manager if @default
    @mapping.manager.policy(@policy_id).amount(@currency_id, @amount).manager rescue nil
  end

  def finance_manager(params={})
    load params
    @mapping.finance_manager.policy(@policy_id).amount(@currency_id, @amount).finance_manager rescue nil
  end

  def approves_to(params={})
    return nil unless user.manager?
    load params
    @mapping.approves_to.policy(@policy_id).amount(@currency_id, @amount).approves_to_user rescue nil
  end

  def approves_finance_to(params={})
    return nil unless user.finance_manager?
    load params
    @mapping.approves_finance_to.policy(@policy_id).amount(@currency_id, @amount).approves_finance_to_user rescue nil
  end

  private
  def load(params={})
    @admin_view = nil
    @manager_view = nil
    @finance_view = nil
    @mapping = nil
    @policy_id = nil
    @currency_id = nil
    @amount = nil

    @policy_id = params[:policy_id]
    @mapping = self.user.team_mapping
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

end