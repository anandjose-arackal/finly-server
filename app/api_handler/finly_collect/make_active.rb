class FinlyCollect::MakeActive < FinlyCollect::Update

  def post_params
    {active: true}.to_json
  end

end