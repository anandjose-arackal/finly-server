class AccountingSystemConfiguration < ActiveRecord::Base
  belongs_to :company

  serialize :options
end
