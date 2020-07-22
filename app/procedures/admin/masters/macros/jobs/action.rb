class Admin::Masters::Macros::Jobs::Action < ActionManager::API

  scope policy: Admin::Masters::Macros::Jobs::Policy, model: MacroJob do
    action :template,
           :run_macro,
           format: 'primary',
           permissions: :admin,
           authorize: :create?,
           label: 'Run Macro',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           function: 'macro_run'
  end

end