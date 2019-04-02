FactoryBot.define do
  factory :doorkeeper_application, class: 'Doorkeeper::Application' do
    name {Faker::Company.name}
    uid {SecureRandom.hex(32)}
    secret {SecureRandom.hex(32)}
    redirect_uri {'urn:ietf:wg:oauth:2.0:oob'}
    scopes {'web'}
  end
end