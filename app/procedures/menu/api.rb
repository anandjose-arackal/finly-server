class Menu::API < Transactions::API
  include DynamicAttributes
  extend ActionManager::DSL

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

  def self.item(key, path: nil, icon: nil, label: nil, permissions: [], features: [], &block)
    items << Menu::Item.new(
        key: key, path: path, icon: icon, label: label,
        permissions: permissions, features: features, scopes: scopes, action_registry: self,
        &block
    )
  end

  def self.scopes
    @scopes ||= []
  end

  def self.scope(path: nil, permissions: [], features: nil, &block)
    scopes.push({path: path, permissions: permissions, features: features})
    instance_eval &block
    scopes.pop
  end

  step :authorize!
  pass :build_menu
  pass :build_modules
  pass :set_current_module

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
    context[:entities] = []

    if current_user.company.group_entity_structure_enabled? and not RequestStore.store[:actual_current_user].present?
      users = User.where(finly_id: current_user.finly_id).includes(company: :configuration)
    else
      users = [current_user]
    end

    users.each do |user|
      company = user.company
      conf = {
          company_id: company.id,
          name: company.name,
          logo: company.configuration.logo.url,
          selected: (current_user == user),
          modules: []
      }

      MODULES_CONFIG.each do |mod|

        next if mod[:feature] and not user.company.feature_subscription.send(mod[:feature])
        next if mod[:user_subscription] and not user.user_panel_subscription.send(mod[:user_subscription])
        if mod[:permissions].present?
          permissions = mod[:permissions]
          permissions = [permissions] unless permissions.respond_to?(:each)
          next if permissions.present? and not user.has_permission?(permissions)
        end

        selected = (current_user == user and [mod[:app].to_s, mod[:app]].include?(RequestStoreUtil.current_app))
        conf[:modules] << mod[:config].merge(selected: selected)
      end

      context[:entities] << conf
    end
  end

  def set_current_module(context, options)
    MODULES_CONFIG.each do |mod|
      next unless [mod[:app].to_s, mod[:app]].include?(RequestStoreUtil.current_app)

      context[:current_module] = mod&.dig(:config, :name)
      break
    end
  end

end