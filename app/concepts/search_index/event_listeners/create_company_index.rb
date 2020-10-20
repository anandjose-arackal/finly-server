class SearchIndex::EventListeners::CreateCompanyIndex

  def work(user, params)
    Indexes::Vp.create_index(params[:record].id)
  end

end