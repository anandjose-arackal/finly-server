# == Schema Information
#
# Table name: receipt_extract_sources
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExpenseDataExtractSource < ActiveRecord::Base
  include Seedable

  def self.values
    [:transcriber, :auto_extract_email]
  end

end
