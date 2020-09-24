class SearchIndex::EventListener

  def work(user, params)
    record = params[:record]
    record.rebuild_search_index
  end

end