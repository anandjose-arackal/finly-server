class NonTenantedApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include EventProducer
  include Ransacker

  self.abstract_class = true

  include SoftDeletable

end