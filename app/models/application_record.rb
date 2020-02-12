class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable, ActiveRecordMaster

  self.abstract_class = true

  # include SoftDeletable

end