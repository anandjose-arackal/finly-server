class Currency < ActiveRecord::Base
  has_many :amounts
end
