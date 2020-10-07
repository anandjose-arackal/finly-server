class BaseJob

  def self.perform
    ActsAsTenant.without_tenant do
      self.perform_job
    end
  end

end
