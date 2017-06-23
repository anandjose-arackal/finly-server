# == Schema Information
#
# Table name: authentications
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  provider         :string(255)
#  uid              :string(255)
#  name             :string(255)
#  email            :string(255)
#  nickname         :string(255)
#  first_name       :string(255)
#  last_name        :string(255)
#  location         :string(255)
#  description      :string(255)
#  image            :string(255)
#  phone            :string(255)
#  urls             :string(255)
#  token            :string(255)
#  secret           :string(255)
#  expires          :boolean
#  expires_at       :datetime
#  refresh_token_at :datetime
#  extra            :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Authentication < ActiveRecord::Base
  belongs_to :user

  scope :quickbooks, -> { where(provider: QuickbooksFinlyIntegratable::ALLOWED_INTEGRATION_TYPES[0]) }
  scope :valid, -> { where('DATE(expires_at) > ?', Date.today) }
end
