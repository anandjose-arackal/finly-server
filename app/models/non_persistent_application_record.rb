class NonPersistentApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Exposures::Model::Exposable

  self.abstract_class = true

end