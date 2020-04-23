class Masters::Users::Action < ActionManager::API

  scope policy: Masters::Users::Policy, model: YesBankVendor do

    action :export,
           :export,
           permissions: [:admin],
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: 'users.vp.index'

    action :template,
           :create,
           permissions: [:admin],
           format: 'primary',
           label: 'Invite User',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           function: 'users_invite'

  end

end