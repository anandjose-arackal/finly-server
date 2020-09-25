class SearchIndex::EventListeners::RecordChange

  def work(user, params)
    record = params[:record]
    record.rebuild_search_index
  end

end