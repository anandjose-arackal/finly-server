class Menu::Processor < Transactions::API

  step :find_master
  step :build_config

  def find_master(context, current_user:, **)
    Menu::Registry.registry.each do |menu|
      next unless menu.accept?(current_user)

      context['master'] = menu
      break
    end

    unless context['master'].present?
      return on_error context, :base, 'Could not process the request'
    end

    true
  end

  def build_config(context, params:, master:, current_user:, **)
    result = master.(params: params, current_user: current_user)
    if result.success?
      context[:menu] = result[:menu]
      context[:entities] = result[:entities]
      context[:current_module] = result[:current_module]
      return true
    end

    Messages::AddSchema(context, context.errors)
    false
  end

end