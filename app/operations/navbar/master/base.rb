class Navbar::Master::Base
  cattr_accessor :data_map

  def self.app
    set_data_map[:app]
  end

  def self.tabs
    set_data_map[:tabs]
  end

  def self.default_cog
    [
        :cog_users,
        :cog_statements,
        :cog_organization_account,
        :cog_load_company_balance,
        :cog_fund_disbursement,
        :cog_expense_management,
        :cog_vendor_payments,
        :cog_finly_collect,
        :cog_finly_insights
    ]
  end

  def self.cog
    default_cog + set_data_map[:cog]
  end

  def self.structure(type)
    set_data_map[type]
  end

  def self.register_app(app)
    set_data_map[:app] = app
  end

  def self.register_structure(type, structure)
    set_data_map[type] = structure
  end

  def self.set_data_map
    if self.data_map.nil?
      self.data_map = {}
    end
    if self.data_map[self.name].nil?
      self.data_map[self.name] = {}
    end
    self.data_map[self.name]
  end

  def self.accept?
    false
  end

  protected
  def user
    RequestStoreUtil.current_user
  end

  # Checking for vendor payments only for uat

  def users
    return nil unless RequestStoreUtil.current_user.vendor_payment_admin?
    {name: 'Users', id: 'users', url: '#users'}
  end

  def load_company_balance
    return nil unless RequestStoreUtil.current_user.vendor_payment_admin?
    {name: 'Load Company Balance', id: 'load-company-balance', url: '#load-company-balance'}
  end

  def statements
    return nil unless RequestStoreUtil.current_user.vendor_payment_admin?
    {name: 'Statements', id: 'statements', url: '#statements'}
  end

  def organization_account
    return nil unless RequestStoreUtil.current_user.vendor_payment_admin?
    {name: 'Organization Account', id: 'organization_account', url: '#organization_account'}
  end

  def finly_expense_management
    return nil unless RequestStoreUtil.current_user.company.expense_management_enabled?
    {name: 'Expense Management', id: 'expense_management', url: '/'}
  end

  def finly_vendor_payments
    return nil unless RequestStoreUtil.current_company.feature_subscription.yes_bank_account and RequestStoreUtil.current_user.user_panel_subscription.yes_bank_account_transfer
    {name: 'Vendor Payments', id: 'vendor_payments', url: '/payments'}
  end

  def finly_disburse
    return nil unless RequestStoreUtil.current_user.user_panel_subscription.disburse && RequestStoreUtil.current_user.company.cards_enabled?
    {name: 'Fund Disbursement', id: 'disburse', url: '/disburse'}
  end

  def finly_collect
    return nil unless RequestStoreUtil.current_company.feature_subscription.invoicing_system && RequestStoreUtil.current_user.user_panel_subscription.invoicing_system
    {name: 'Finly Collect', id: 'collect', url: '/collect'}
  end

  def finly_insights
    return nil unless RequestStoreUtil.current_company.feature_subscription.budgeting_system # && RequestStoreUtil.current_user.is_budget_manager?
    {name: 'Finly Insights', id: 'insights', url: '/insights'}
  end

end