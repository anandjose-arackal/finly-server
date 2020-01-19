class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include ActiveRecordMaster
  include Resolver::ActiveRecordHelper

  self.abstract_class = true

end