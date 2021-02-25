# == Schema Information
#
# Table name: ml_models
#
#  id                :bigint           not null, primary key
#  company_id        :integer          not null
#  parent_type       :string(255)
#  parent_id         :bigint
#  type              :string(255)      not null
#  config            :text(4294967295)
#  built_at          :datetime
#  build_schedule    :string(255)
#  track_schedule    :string(255)
#  build_duration    :integer
#  tracked_at        :datetime
#  algorithm         :string(255)
#  target_key        :string(255)      not null
#  target_key_type   :string(255)      not null
#  split_key         :string(255)
#  split_key_type    :string(255)
#  model_klass       :string(255)
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  pmml_file_name    :string(255)
#  pmml_content_type :string(255)
#  pmml_file_size    :bigint
#  pmml_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe MlModel, type: :model do



end
