FactoryBot.define do

  factory :request, class: Hash do
    ip Faker::Internet.ip_v4_address
    factory :browser_auth_request
    map = UserDeviceBrowser.obfuscation_map
    headers {{
        'X-Finly-RP' => Base64.encode64(
            {
                "#{UserDeviceBrowser.client_id}" => {
                    "#{map[:timestamp_s]}" => DateTime.now.strftime('%Q'),
                    "#{map[:user_agent]}" => Faker::Internet.user_agent,
                    "#{map[:timezone]}" => 'Indian Standard Timezone',
                    "#{map[:fingerprint]}" => SecureRandom.hex(32),
                    "#{map[:language]}" => 'english'
                }
            }
        )
    }}

    initialize_with {attributes}
  end

end