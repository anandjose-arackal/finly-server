class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include EventProducer
  include Ransacker

  self.abstract_class = true

  include SoftDeletable

  acts_as_tenant(:company, options = {
    has_global_records: true,
  })

  before_validation Proc.new {|m|
    if ActsAsTenant.current_tenant && m.company_id.nil?
      m.company_id = ActsAsTenant.current_tenant.id
    end
  }, :on => :update

end