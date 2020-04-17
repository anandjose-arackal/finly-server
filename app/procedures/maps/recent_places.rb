class Maps::RecentPlaces < Transactions::API

  pass :find_recent

  def find_recent(context, current_user:, **)
    context['model.index'] = current_user.map_location_user_queries.reorder(created_at: :desc).limit(5)

  end

end