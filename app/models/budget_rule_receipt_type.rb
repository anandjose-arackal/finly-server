class BudgetRuleReceiptType < ActiveRecord::Base
  include Seedable

  def self.values
    [:any, :with_receipt, :without_receipt]
  end

end
