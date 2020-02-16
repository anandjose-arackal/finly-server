# == Schema Information
#
# Table name: expense_data_extract_sources
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class ExpenseDataExtractSource < ApplicationRecord
  include Seedable

  def self.values
    [:transcriber, :auto_extract_email]
  end

end
