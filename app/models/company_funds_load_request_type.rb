class CompanyFundsLoadRequestType < ActiveRecord::Base
  include Seedable

  def self.values
    [:itzcash, :yesbank]
  end
end