# == Schema Information
#
# Table name: user_device_browsers
#
#  id                     :bigint(8)        not null, primary key
#  timestamp              :datetime
#  user_agent             :string(255)
#  timezone               :string(255)
#  fingerprint            :string(255)
#  language               :string(255)
#  system_language        :string(255)
#  browser                :string(255)
#  browser_version        :string(255)
#  browser_engine         :string(255)
#  browser_engine_version :string(255)
#  os_name                :string(255)
#  os_version             :string(255)
#  screen_width           :integer
#  screen_height          :integer
#  device_x_dpi           :integer
#  device_y_dpi           :integer
#  color_depth            :integer
#  java_enabled           :boolean
#  java_version           :string(255)
#  flash_enabled          :boolean
#  flash_version          :string(255)
#  silver_light_enabled   :boolean
#  silver_light_version   :string(255)
#  is_mime_types          :boolean
#  mime_types_list        :string(255)
#  fonts_list             :text(65535)
#  is_local_storage       :boolean
#  is_session_storage     :boolean
#  is_cookie              :boolean
#  plugins                :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_mobile              :boolean
#

require 'test_helper'

class UserDeviceBrowserTest < ActiveSupport::TestCase

  def setup

  end

  test 'find_or_create should create if not found' do

  end

end
