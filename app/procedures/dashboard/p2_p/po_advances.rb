class Dashboard::P2P::POAdvances < Dashboard::IndexCard

  index_route 'po_advances'
  path 'po_advances'
  policy :policy_id
  location :delivery_location_id
  department :items_department_id
  cost_center :items_cost_center_id
  created_by :user_id
  scope_status AdvanceAmountStatus.id_for(:to_be_processed)
  skip_admin!

end