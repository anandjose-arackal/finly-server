class ActionManager::Actions::Macro < ActionManager::Action

  config :route
  register :macro

  def build_config(options)
    user = options[:current_user]
    route = self.config[:route]
    config = []
    user.company.macros.with_route(route).each do |macro|
      next unless macro.active?
      next unless Macros::Jobs::Policy.new(user, macro).create?

      config << {
          id: macro.id,
          name: macro.name,
          description: macro.description
      }
    end
    config
  end

end