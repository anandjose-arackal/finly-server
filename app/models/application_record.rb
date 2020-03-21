class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include EventProducer

  self.abstract_class = true

  # include SoftDeletable

end