# == Schema Information
#
# Table name: feedback_types
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class FeedbackType < ActiveRecord::Base

  VALUES = {issue_report: 1, feature_request: 2, appreciation: 3, others: 4}

  DESCRIPTIONS = {
      issue_report: 'Report issues in the system',
      feature_request: 'Request for new features',
      appreciation: 'Appreciation for product / feature',
      others: 'Others'
  }

  def self.seed_data
    if FeedbackType.count == 0
      FeedbackType::VALUES.each do |key, value|
        description = FeedbackType::DESCRIPTIONS[key]
        FeedbackType.create id: value, name: key.to_s, description: description
      end
    end
  end

  def self.id_for(key)
    VALUES[key]
  end

end
