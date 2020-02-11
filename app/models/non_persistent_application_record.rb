class NonPersistentApplicationRecord < ActiveRecord::Base
  include LiquidDroppable

  self.abstract_class = true

end