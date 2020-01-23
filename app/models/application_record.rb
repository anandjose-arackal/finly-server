class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include Resolver::ActiveRecordHelper

  self.abstract_class = true

end