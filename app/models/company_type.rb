# == Schema Information
#
# Table name: company_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CompanyType < ActiveRecord::Base
  include Seedable

  def self.values
    ['Sole Proprietor', 'Partnership Firm', 'Private Ltd Company', 'Ltd Company', 'Ltd Liability Partnership', 'Trust and Societies']
  end
end
