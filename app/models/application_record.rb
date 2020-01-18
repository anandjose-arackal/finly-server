class ApplicationRecord < ActiveRecord::Base
  include LiquidDroppable
  include ActiveRecordMaster
  include Transactions::Resolver::ActiveRecordHelper

  self.abstract_class = true

end