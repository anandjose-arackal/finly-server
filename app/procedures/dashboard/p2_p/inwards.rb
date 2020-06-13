class Dashboard::P2P::Inwards < Dashboard::IndexCard

  index_route 'receive'
  path 'receive'
  id 'receive_pending'
  created_by :user_id
  skip_admin!

end