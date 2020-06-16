class Dashboard::P2P::UtilityBills < Dashboard::IndexCard

  index_route 'utility_bills'
  path 'utility_bills'
  created_by :user_id
  policy :policy_id
  location :location_id
  cost_center :cost_center_id
  department :department_id
  skip_personal!

end