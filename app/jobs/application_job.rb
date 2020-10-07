class ApplicationJob < ActiveJob::Base
  around_perform :set_non_tenant

  def set_non_tenant
    ActsAsTenant.without_tenant do
      yield
    end
  end

end