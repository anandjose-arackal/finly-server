class Navbar::Master::Collect::NavConfig < Navbar::Master::Base

  register_app :fc
  register_structure(
      [
          :customers,
          :transactions,
          :inventory,
          :invoices,
          :virtual_accounts
      ]
  )

end