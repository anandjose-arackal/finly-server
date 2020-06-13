class Dashboard::P2P::Inwards < Dashboard::IndexCard

  index_route 'receive'
  path 'receive'
  id 'receive_pending'
  created_by :user_id
  policy :policy_id
  department :items_department_id
  cost_center :items_cost_center_id
  location :delivery_location_id
  skip_admin!

end