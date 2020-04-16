class Masters::Items::Action < ActionManager::API

  scope policy: Masters::Items::Policy, model: YesBankVendor do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "item_master.index",
           authorize: :export?

    action :template,
           :create,
           permissions: [:admin, :item_master_manager],
           format: 'primary',
           label: 'Add Item',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           function: 'items_create'

  end

end