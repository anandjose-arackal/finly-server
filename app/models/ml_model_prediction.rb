# == Schema Information
#
# Table name: ml_model_predictions
#
#  id                     :bigint           not null, primary key
#  company_id             :integer          not null
#  ml_model_id            :bigint
#  record_type            :string(255)
#  record_id              :bigint
#  actual_value           :string(255)
#  predicted_value        :string(255)
#  is_accurate_prediction :boolean
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class MlModelPrediction < ApplicationRecord
  belongs_to :company
  belongs_to :ml_model
  belongs_to :ml_model_pmml
  belongs_to :record, polymorphic: true

  scope :accurate, -> { where(is_accurate_prediction: true) }

  before_save do
    self.is_accurate_prediction = (actual_value.to_s == predicted_value.to_s)
  end

  def self.measure
    total_measures = self.count
    accurate_measures = self.where(is_accurate_prediction: true).count
    puts "Accuracy: #{accurate_measures * 100 / total_measures}% (#{total_measures} samples)"
  end
end
