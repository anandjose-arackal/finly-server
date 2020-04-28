class Masters::RateContracts::Action < ActionManager::API

  scope policy: Masters::RateContracts::Policy, model: RateContract do
    action :redirect,
           :create,
           permissions: [:inventory_manager, :admin],
           authorize: :create?,
           format: 'primary',
           label: 'New Rate Contract',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'rate_contracts/new'
  end

end