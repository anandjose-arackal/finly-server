class SearchIndex::EventListeners::RecordChange

  def work(user, params)
    params[:record].search_index.index_record(params[:record])
  end

end