class Masters::Items::Resolver < Resolver::API

  entity Item

  def load(params)
    user.company.items.non_deleted
  end

end