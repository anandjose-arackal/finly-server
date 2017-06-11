# == Schema Information
#
# Table name: receipt_email_data_point_modes
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReceiptEmailDataPointMode < ActiveRecord::Base
  include Seedable

  def self.values
    [:xpath_only, :css_selector_only, :xpath_first, :css_selector_first]
  end

end
