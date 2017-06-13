# == Schema Information
#
# Table name: expense_data_extract_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseDataExtractStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:pending, :failed, :illegible, :partial_extract, :success]
  end

end
