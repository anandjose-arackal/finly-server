class CompanyStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:active, :partial_block, :deactivated, :hidden]
  end

end
