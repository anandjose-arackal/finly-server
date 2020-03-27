class Menu::API < Transactions::API
  include DynamicAttributes

  MODULES_CONFIG = [
      {
          config: {name: 'Expense Management', id: 'expense_management', url: '/'},
          feature: :expense_management_enabled, app: :em
      },
      {
          config: {name: 'Vendor Payments', id: 'vendor_payments', url: '/payments'},
          feature: :yes_bank_account, user_subscription: :yes_bank_account_transfer, app: :vp
      },
      {
          config: {name: 'Finly Budgets', id: 'insights', url: '/insights'},
          feature: :budgeting_system, permissions: :budget_manager, app: :fi
      }
  ]

  class_attr :app

  def self.inherited(sub_class)
    Menu::Registry.register(sub_class)
    super
  end

  def self.accept?(user)
    false
  end

  def self.items
    @items ||= []
  end

  def self.item(key, path: nil, icon: nil, label: nil, create: false, permissions: [], features: [], &block)
    items << Menu::Item.new(
        key: key, path: path, icon: icon, label: label, create: create,
        permissions: permissions, features: features, scopes: scopes,
        &block
    )
  end

  def self.scopes
    @scopes ||= []
  end

  def self.scope(path: nil, create: false, permissions: [], features: nil, &block)
    scopes.push({path: path, create: create, permissions: permissions, features: features})
    instance_eval &block
    scopes.pop
  end

  step :authorize!
  pass :build_menu
  pass :build_modules

  def authorize!(context, current_user:, **)
    error = false
    error ||= RequestStoreUtil.current_app.blank?
    error ||= RequestStoreUtil.current_app.to_s != self.class.app.to_s
    error ||= current_user.blank?
    return on_error(context, :base, "unauthorized!") if error

    true
  end

  def build_menu(context, current_user:, **)
    context[:menu] = self.class.items.as_json(current_user: current_user).reject { |item| item.nil? }
  end

  def build_modules(context, current_user:, **)
    context[:modules] = []
    MODULES_CONFIG.each do |mod|
      next if [mod[:app].to_s, mod[:app]].include?(RequestStoreUtil.current_app)
      next if mod[:feature] and not current_user.company.feature_subscription.send(mod[:feature])
      next if mod[:user_subscription] and not current_user.user_panel_subscription.send(mod[:user_subscription])
      if mod[:permissions].present?
        permissions = mod[:permissions]
        permissions = [permissions] unless permissions.respond_to?(:each)
        next if permissions.present? and not current_user.has_roles?(permissions)
      end

      context[:modules] << mod[:config]
    end
  end

end