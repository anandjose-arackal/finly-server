require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe Admin::CompanyGroupsController, type: :request do
  before :all do
    @doorkeeper_application = create :doorkeeper_application, scopes: 'admin'
    @admin_user1 = create :admin_user, email: generate(:admin_user_email), mobile_number: generate(:user_mobile_number)
    # nosqli - These are TDD test cases that mock behavior for unit testing, these are not real credentials that work in Prod
    @password = 'FW1g$18j0t!k2'

    @user_agent = Faker::Internet.user_agent
    @ip = RequestHelper.random_ip
    @fingerprint = RequestHelper.random_fingerprint
    @headers = RequestHelper.authentication_headers_for(:web, fingerprint: @fingerprint)
    @headers[:HTTP_USER_AGENT] = @user_agent
    @headers[:REMOTE_ADDR] = @ip

    RSpec::Mocks.with_temporary_scope do
      post '/admin/oauth/token', params: {
        email: @admin_user1.email,
        password: @password,
        client_id: @doorkeeper_application.uid,
        client_secret: @doorkeeper_application.secret
      }, headers: @headers.deep_dup
      @body = JSON.parse response.body
      @token_value = @body&.dig('data', 'access_token')
    end

    @headers['Authorization'] = "Bearer #{@token_value}"
  end

  describe "GET #index" do
    it "returns http 200" do
      get '/admin/index.json?route=admin.company_groups', headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    it "return http 200" do
      post '/admin/company_groups/', params: {
        name: "First Organization"
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end

    it 'return http 422 with invalid data' do
      post '/admin/company_groups', params: {}, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it 'returns correct data on successful create' do
      post '/admin/company_groups', params: {
        name: "Second Organization"
      }, headers: @headers.deep_dup

      actual_response = JSON.parse(response.body)
      expect(actual_response).to have_key "data"
      expect(actual_response["data"]).to have_key "id"
      expect(actual_response["data"]).to have_key "created_at"
      expect(actual_response["data"]).to have_key "updated_at"

      expected_response = {
        data: {
          id: actual_response["data"]["id"],
          name: "Second Organization",
          created_at: actual_response["data"]["created_at"],
          updated_at: actual_response["data"]["updated_at"],
          default_company_id: nil,
          deleted_at: nil
        },
        success: true,
        messages: {
          success: ["Organisation created"],
          errors: [],
          errors_meta: {}
        }
      }.as_json
      expect(actual_response).to eq expected_response
    end
  end

  describe "GET #show and PUT #update" do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        post '/admin/company_groups', params: {
          name: "Second Organization"
        }, headers: @headers.deep_dup
        @org_data = JSON.parse(response.body)["data"]
      end
    end

    describe "GET #show" do
      it "returns correct response" do
        get "/admin/company_groups/#{@org_data['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          data: @org_data,
          success: true,
          messages: {
            errors: [],
            errors_meta: {},
            success: []
          }
        }.as_json

        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    describe "PUT #update" do
      it "returns correct response" do
        put "/admin/company_groups/#{@org_data['id']}", params: {
          name: "Second Organization 2"
        }, headers: @headers.deep_dup

        actual_response = JSON.parse(response.body)
        expect(actual_response["data"]).to have_key "updated_at"

        expected_org_data = @org_data.deep_dup
        expected_org_data["updated_at"] = actual_response["data"]["updated_at"]
        expected_org_data["name"] = "Second Organization 2"

        expected_response = {
          data: expected_org_data,
          success: true,
          messages: {
            errors: [],
            errors_meta: {},
            success: ["Organisation updated"]
          }
        }.as_json

        expect(JSON.parse(response.body)).to eq expected_response
      end

    end
  end
end