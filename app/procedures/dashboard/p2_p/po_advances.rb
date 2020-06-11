class Dashboard::P2P::POAdvances < Dashboard::IndexCard

  index_route 'po_advances'
  path 'po_advances'
  # created_by :user_id
  scope_status AdvanceAmountStatus.id_for(:to_be_processed)
  skip_admin!

end