require 'rails_helper'
RSpec.describe 'Rack::Attack' do

  before :each do
    setup_rack_attack_cache_store
    avoid_test_overlaps_in_cache
  end

  def setup_rack_attack_cache_store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  def avoid_test_overlaps_in_cache
    Rails.cache.clear
  end

  [
      {key: :lookup, path: '/lookup.json', method: :get},
      {key: :token, path: '/oauth/token.json', method: :post},
      {key: :send_otp, path: '/send_verification_otp.json', method: :post},
      {key: :verify_otp, path: '/verify_user_otp.json', method: :post},
      {key: :set_password, path: '/users/password.json', method: :post}
  ].each do |request_props|
    [
        {requests: 3, period: 6, queue: "#{request_props[:key]} throttling - 6 seconds"},
        {requests: 20, period: 60, queue: "#{request_props[:key]} throttling - 1 minute"},
        {requests: 40, period: 600, queue: "#{request_props[:key]} throttling - 10 minute"},
        {requests: 60, period: 6000, queue: "#{request_props[:key]} throttling - 100 minute"},
        {requests: 200, period: 60000, queue: "#{request_props[:key]} throttling - 1000 minute"}
    ].each do |limit|
      describe "> #{request_props[:key]}" do
        it "should not allow more than #{limit[:requests]} per #{limit[:period]} seconds" do
          avoid_test_overlaps_in_cache
          ip = '1.2.3.4'
          limit[:requests].times.each do
            Rack::Attack.cache.count("#{limit[:queue]}:#{ip}", limit[:period])
          end

          self.send request_props[:method], request_props[:path], headers: {REMOTE_ADDR: ip}
          expect(response).to have_http_status(:too_many_requests)
        end
      end
    end
  end

end