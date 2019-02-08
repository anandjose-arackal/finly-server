# == Schema Information
#
# Table name: user_session_webs
#
#  id                        :bigint(8)        not null, primary key
#  timestamp                 :datetime
#  user_agent                :string(255)
#  timezone                  :string(255)
#  fingerprint               :string(255)
#  language                  :string(255)
#  system_language           :string(255)
#  browser                   :string(255)
#  browser_version           :string(255)
#  browser_engine            :string(255)
#  browser_engine_version    :string(255)
#  os_name                   :string(255)
#  os_version                :string(255)
#  screen_width              :integer
#  screen_height             :integer
#  current_resolution_width  :integer
#  current_resolution_height :integer
#  device_x_dpi              :integer
#  device_y_dpi              :integer
#  color_depth               :integer
#  mouse_pos_x               :integer
#  mouse_pos_y               :integer
#  java_enabled              :boolean
#  java_version              :string(255)
#  flash_enabled             :boolean
#  flash_version             :string(255)
#  silver_light_enabled      :boolean
#  silver_light_version      :string(255)
#  is_mime_types             :boolean
#  mime_types_list           :string(255)
#  fonts_list                :text(65535)
#  current_font              :string(255)
#  is_local_storage          :boolean
#  is_session_storage        :boolean
#  is_cookie                 :boolean
#  plugins                   :text(65535)
#  screen_print              :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class UserSessionWebTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
