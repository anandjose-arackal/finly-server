class ActionManager::Actions::Macro < ActionManager::Action

  config :route
  register :macro

  def build_config(options)
    user = options[:current_user]
    config = []
    user.company.macros.each do |macro|
      permissions = macro.permissions
      # Permissions are not defined, scope it only to 'admin'
      permissions = [:admin] if permissions.blank?
      next unless user.has_permission?(permissions)

      config << {
          macro_key: macro.macro_key,
          name: name,
          description: description
      }
    end
    config
  end

end