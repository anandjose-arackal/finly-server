class Forms::Resolver < Transactions::Resolver::Scope

  def load(params)
    scope.where(company_id: @user.company_id)
  end

end