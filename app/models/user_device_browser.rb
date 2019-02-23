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

class UserDeviceBrowser < ApplicationRecord
  attr_accessor :timestamp_s

  # validates :timestamp, presence: true
  # validates :user_agent, presence: true
  # validates :timezone, presence: true
  # validates :fingerprint, presence: true
  # validates :language, presence: true
  # validates :browser, presence: true
  # validates :browser_version, presence: true
  # validates :browser_engine, presence: true
  # validates :browser_engine_version, presence: true
  # validates :os_name, presence: true
  # validates :os_version, presence: true
  # validates :screen_width, presence: true
  # validates :screen_height, presence: true
  # validates :color_depth, presence: true
  # validates :is_mobile, presence: true

  before_save :set_timestamp

  # {
  #     '11': '1549636286',
  #     '16': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.96 Safari/537.36',
  #     '19': 'India Standard Time',
  #     '7': '3202771635',
  #     '5': 'en-IN',
  #     '20': nil,
  #     '27': 'Chrome',
  #     '21': '72.0.3626.96',
  #     '8': 'WebKit',
  #     '23': '537.36',
  #     '18': 'Mac OS',
  #     '25': '10.14.1',
  #     '10': '1920',
  #     '24': '1080',
  #     '2': nil,
  #     '26': nil,
  #     '13': '24',
  #     '15': false,
  #     '17': nil,
  #     '30': false,
  #     '12': nil,
  #     '29': false,
  #     '6': nil,
  #     '9': true,
  #     '4': ', Portable Document Format, Native Client Executable, Portable Native Client Executable',
  #     '1': 'Adobe Fangsong Std, Adobe Hebrew, Adobe Ming Std, Arial Black, Arial, Bauhaus 93, Calibri, Chalkduster, Comic Sans MS, Courier New, Georgia, Hiragino Sans GB, Impact, Kozuka Gothic Pr6N, Menlo, Microsoft Sans Serif, Papyrus, Plantagenet Cherokee, Rockwell, Symbol, Tahoma, Times New Roman, Trebuchet MS, Verdana, Webdings, Wingdings',
  #     '3': true,
  #     '14': true,
  #     '22': true,
  #     '28': 'Chrome PDF Plugin, Chrome PDF Viewer, Native Client',
  #     '31': true
  # }

  def incomplete?
    set_timestamp
    [
        :timestamp, :user_agent, :timezone, :fingerprint, :language,
        :browser, :browser_version, :browser_engine, :browser_engine_version,
        :os_name, :os_version,
        :screen_width, :screen_height, :color_depth, :is_mobile
    ].each do |attr|
      if self.send(attr).blank?
        return true
      end
    end
    false
  end

  def self.obfuscation_map
    {
        timestamp_s: '11',
        user_agent: '16',
        timezone: '19',
        fingerprint: '7',
        language: '5',
        system_language: '20',
        browser: '27',
        browser_version: '21',
        browser_engine: '8',
        browser_engine_version: '23',
        os_name: '18',
        os_version: '25',
        screen_width: '10',
        screen_height: '24',
        device_x_dpi: '2',
        device_y_dpi: '26',
        color_depth: '13',
        java_enabled: '15',
        java_version: '17',
        flash_enabled: '30',
        flash_version: '12',
        silver_light_enabled: '29',
        silver_light_version: '6',
        is_mime_types: '9',
        mime_types_list: '4',
        fonts_list: '1',
        is_local_storage: '3',
        is_session_storage: '14',
        is_cookie: '22',
        plugins: '28',
        is_mobile: '31'
    }
  end

  def set_timestamp
    self.timestamp = DateTime.strptime(self.timestamp_s, '%s') if timestamp_s.present? and self.timestamp.blank?
  end


end
