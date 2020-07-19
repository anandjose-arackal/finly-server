class ActionManager::Actions::Macro < ActionManager::Action

  config :route
  register :macro

  def build_config(options)
    user = options[:current_user]
    config = []
    user.company.macros.each do |macro|
      next unless Macros::Jobs::Policy.new(user, macro).create?

      config << {
          macro_key: macro.macro_key,
          name: name,
          description: description
      }
    end
    config
  end

end