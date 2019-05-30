json.data do
  @result.params[:filter_purpose]&.each do |purpose|
    json.set! purpose, @result.get(purpose)
  end
end
