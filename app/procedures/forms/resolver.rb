class Forms::Resolver < Transactions::Resolver::Scope

  def load(user, params)
    Success(scope.where(company_id: user.company_id))
  end

end