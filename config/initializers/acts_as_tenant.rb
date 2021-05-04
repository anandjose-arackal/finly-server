require 'acts_as_tenant/sidekiq'

ActsAsTenant.configure do |config|
  config.require_tenant = true
end

module ActsAsTenant
  # self.without_tenant_if_not_set

  def self.without_tenant_if_not_set(&block)
    if block.nil?
      raise ArgumentError, "block required"
    end

    if current_tenant.present?
      value = block.call
      return value
    end

    self.without_tenant(&block)
  end
end