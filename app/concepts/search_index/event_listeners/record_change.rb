class SearchIndex::EventListeners::RecordChange

  def work(user, params)
    puts "Record: #{params[:record].as_json}"
    params[:record].search_index.index_record(params[:record])
  end

end