class Docs::ExpenseManagement::MoneyRequests::Resolver < Resolver::API

    entity MoneyRequest
  
    def load(params)
      reports = nil
      if user.admin?(:em)
        money_requests = MoneyRequest.where(company_id: user.company_id)
      else
        money_requests = user.money_requests
      end

      money_requests
    end
  
end