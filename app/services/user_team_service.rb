class UserTeamService
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def team(params)
    return nil if user.employee?

  end

  def manager(params)
    load params
    # todo validate if its better to go with rescue when manager is not assigned or have a seperate check which might result in 2 queries
    # return nil unless self.user.team_mapping.manager.present? # todo sample check
    return @items.default.manager if @default
    @items.manager.policy(@policy_id).first.manager rescue nil
  end

  def finance_manager(params)
    load params
    return @items.default.finance_manager if @default
    @items.finance_manager.policy(@policy_id).first.finance_manager rescue nil
  end

  def approves_to(params)
    return nil unless user.manager?
    load params
    return @items.default.approves_to_user if @default
    self.user.team_mapping.approves_to.policy(@policy_id).first.approves_to_user rescue nil
  end

  def approves_finance_to(params)
    return nil unless user.finance_manager?
    load params
    return @items.default.approves_finance_to_user if @default
    self.user.team_mapping.approves_finance_to.policy(@policy_id).first.approves_finance_to_user rescue nil
  end

  private
  def load(params)
    @policy_id = params[:policy_id]
    @default = true if params[:default] or @policy_id.blank?
    @items = self.user.team_mapping
  end

end