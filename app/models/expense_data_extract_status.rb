class ExpenseDataExtractStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:pending, :failed, :illegible, :partial_extract, :success]
  end

end
