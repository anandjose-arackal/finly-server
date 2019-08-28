class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable

  self.abstract_class = true

end