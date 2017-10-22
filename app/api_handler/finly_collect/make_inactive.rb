class FinlyCollect::MakeInactive < FinlyCollect::Update

  def post_params
    {active: false}.to_json
  end

end