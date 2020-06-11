class Dashboard::P2P::UtilityBills < Dashboard::IndexCard

  index_route 'utility_bills'
  path 'utility_bills'
  created_by :user_id
  # skip_admin!
  skip_personal!

end