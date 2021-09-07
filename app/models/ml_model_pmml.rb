# == Schema Information
#
# Table name: ml_model_pmmls
#
#  id                :bigint           not null, primary key
#  company_id        :integer          not null
#  ml_model_id       :integer          not null
#  pmml              :text(4294967295)
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  pivot             :string(255)
#  accuracy          :float(24)        default(0.0)
#  predicted_records :integer          default(0)
#
class MlModelPmml < ApplicationRecord
  belongs_to :company
  belongs_to :ml_model
  has_many :predictions, class_name: "MlModelPrediction"

  default_scope { sort_by_accuracy }

  scope :sort_by_accuracy, -> { order(accuracy: :desc) }

  def predict(data)
    return nil unless pmml.present?

    @model ||= Eps::Model.load_pmml(pmml)
    @model.predict(data)
  end

  def compute_accuracy
    predictions_count = predictions.reload.count
    if predictions_count == 0
      update(accuracy: 0)
    else
      accuracy = predictions.accurate.count * 100 / predictions_count
      update(accuracy: accuracy, predicted_records: predictions_count)
    end    
  end
end
