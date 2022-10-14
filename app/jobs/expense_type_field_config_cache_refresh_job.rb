class ExpenseTypeFieldConfigCacheRefreshJob < ApplicationJob

  def perform(company_id, user_id)
    company = Company.find_by id: company_id
    ActsAsTenant.with_tenant company do
      user = User.find_by id: user_id
      cache = ExpenseTypeFieldConfigCache.new user
      cache.refresh
    end
  end
end
