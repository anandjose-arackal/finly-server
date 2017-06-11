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

  def xpath_only?
    self.id == self.class.id_for(:xpath_only)
  end

  def css_selector_only?
    self.id == self.class.id_for(:xpath_only)
  end

  def xpath_first?
    self.id == self.class.id_for(:xpath_only)
  end

  def css_selector_first?
    self.id == self.class.id_for(:xpath_only)
  end

end
