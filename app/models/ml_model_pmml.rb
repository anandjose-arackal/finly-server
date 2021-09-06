# == Schema Information
#
# Table name: ml_model_pmmls
#
#  id          :bigint           not null, primary key
#  company_id  :integer          not null
#  ml_model_id :integer          not null
#  pmml        :text(4294967295)
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  pivot       :string(255)
#
class MlModelPmml < ApplicationRecord
  belongs_to :company
  belongs_to :ml_model
end
