class Admin::Masters::Macros::Action < ActionManager::API

  scope policy: Admin::Masters::Macros::Policy, model: Macro do
    action :redirect,
           :create,
           permissions: [:admin],
           format: 'primary',
           label: 'New Macro',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'macros/new'
  end

end