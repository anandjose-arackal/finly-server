# == Schema Information
#
# Table name: google_maps_configs
#
#  id         :bigint           not null, primary key
#  device     :string(255)      not null
#  api_token  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe GoogleMapsConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
