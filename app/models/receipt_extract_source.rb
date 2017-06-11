# == Schema Information
#
# Table name: receipt_extract_sources
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReceiptExtractSource < ActiveRecord::Base

  scope :with_name, -> (name) {where name: name}

  validates :name, presence: true

  VALUES = {transcriber: 1}

  def self.seed_data
    count = ReceiptExtractSource.count
    VALUES.each do |key, value|
      if count == 0 or ReceiptExtractSource.with_name(key).blank?
        ReceiptExtractSource.create id: value, name: key
      end
    end
  end

end
