class Masters::States::Resolver < Resolver::API

  entity State

  def load(params)
    State.all
  end

end