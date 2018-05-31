class ExpenseTaxType < ActiveRecord::Base
  include Seedable

  def self.values
    [:none, :gst, :tds, :gst_tds]
  end

end
