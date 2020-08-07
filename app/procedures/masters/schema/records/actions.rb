class Masters::Schema::Records::Actions < ActionManager::API

  scope policy: Masters::Schema::Records::Policy do

    # action :macro,
    #        :jobs,
    #        policy: Macros::Jobs::Policy,
    #        authorize: :create?,
    #        route: 'invoices.index',
    #        label: "Jobs",
    #        icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png"

    # action :export,
    #        :export,
    #        label: "Export",
    #        icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
    #        route: "invoices.index"
    #
    # action :template,
    #        :create,
    #        format: 'primary',
    #        permissions: :admin,
    #        label: "Bulk Create",
    #        icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
    #        function: "create_master"

  end

end