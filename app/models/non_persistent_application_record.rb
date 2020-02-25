class NonPersistentApplicationRecord < ActiveRecord::Base
  include LiquidDroppable, ActiveRecordMaster

  self.abstract_class = true

end