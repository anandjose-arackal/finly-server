require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe ExportJobsController, type: :request do
  before :all do
    @doorkeeper_application = create :doorkeeper_application
    @company1 = create :company
    @user1 = create :vp_user, company: @company1, mobile_number: generate(:user_mobile_number), email: generate(:finly_user_email), finly_id: 'test1'
    @user_profile1 = create :user_profile, user: @user1
    @password = 'FW1g$18j0t!k2'

    @user_agent = Faker::Internet.user_agent
    @ip = RequestHelper.random_ip
    @fingerprint = RequestHelper.random_fingerprint
    @headers = RequestHelper.authentication_headers_for(:web, fingerprint: @fingerprint)
    @headers[:HTTP_USER_AGENT] = @user_agent
    @headers[:REMOTE_ADDR] = @ip

    RSpec::Mocks.with_temporary_scope do
      post '/oauth/token.json', params: {
        email: @user1.email,
        password: @password,
        client_id: @doorkeeper_application.uid,
        client_secret: @doorkeeper_application.secret
      }, headers: @headers.deep_dup
      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
      @session = UserSession.last
    end

    @headers['Authorization'] = "Bearer #{@token_value}"
  end

  describe "POST #create" do
    it "template export returns http 200" do
      post '/exports/invoices.json', params: {
        "template_id":ExportTemplateNew.where(company_id: @company1.id, resource: 'invoices').first.id,
        "q":{"g":[]},
        "qs":{"with_status_id":""},
        "note":"",
        # "filter_ids":[]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(200)
      response_data = JSON.parse(response.body)

      expect(response_data['success']).to eq true
      expect(response_data).to have_key "job_id"
    end
  end
end
