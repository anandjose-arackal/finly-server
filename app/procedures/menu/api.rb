class Menu::API < Transactions::API
  include DynamicAttributes

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
  step :build

  def authorize!(context, current_user:, **)
    error = false
    error ||= RequestStoreUtil.current_app.blank?
    error ||= RequestStoreUtil.current_app.to_s != self.class.app.to_s
    error ||= current_user.blank?
    return on_error(context, :base, "unauthorized!") if error

    true
  end

  def build(context, current_user:, **)
    context['config'] = self.class.items.as_json(current_user: current_user).reject { |item| item.nil? }

    true
  end

end