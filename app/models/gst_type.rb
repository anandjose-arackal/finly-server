# == Schema Information
#
# Table name: gst_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GstType < ApplicationRecord
  include Seedable

  def self.values
    [:igst, :cgst_sgst]
  end

  def igst?
    self.id == GstType.id_for(:igst)
  end

  def cgst_sgst?
    self.id == GstType.id_for(:cgst_sgst)
  end
  alias_method :sgst?, :cgst_sgst?
  alias_method :cgst?, :cgst_sgst?

end
