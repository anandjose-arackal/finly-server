class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Resolver::ActiveRecordHelper
  include EventProducer

  self.abstract_class = true

  # include SoftDeletable

end