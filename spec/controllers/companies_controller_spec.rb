require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe CompaniesController, type: :request do
  before :all do
    @doorkeeper_application = create :doorkeeper_application
    @company_group1 = create :company_group
    @company1 = create :company, group: @company_group1
    @user1 = create :vp_admin_user, company: @company1, mobile_number: generate(:user_mobile_number), email: generate(:finly_user_email), finly_id: 'test1'
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

  describe "GET #index" do
    it "returns http 200" do
      get '/index/companies.json', headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    it "return http 200" do
      post '/companies', params: {
        name: "First Company",
        configuration: {
          legal_entity_name: "First Company Legal",
          logo: nil,
          start_date: '2021-01-01',
          end_date: '2022-01-01',
        }
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end

    it 'return http 422 with invalid data' do
      post '/companies', params: {}, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it 'returns correct data on successful create' do
      post '/companies', params: {
        name: "Second Company",
        configuration: {
          legal_entity_name: "Second Company Legal",
          logo: nil,
          start_date: '2021-01-01',
          end_date: '2022-01-01',
        }
      }, headers: @headers.deep_dup

      actual_response = JSON.parse(response.body)
      expect(actual_response).to have_key "data"
      expect(actual_response["data"]).to have_key "id"
      expect(actual_response["data"]).to have_key "created_at"
      expect(actual_response["data"]).to have_key "updated_at"

      expected_response = {
        data: {
          id: actual_response["data"]["id"],
          name: "Second Company",
          configuration: {
            legal_entity_name: "Second Company Legal",
            logo: '/logos/original/missing.png',
            start_date: '2021-01-01',
            end_date: '2022-01-01'
          },
          active: true,
          created_at: actual_response["data"]["created_at"],
          updated_at: actual_response["data"]["updated_at"],
        },
        success: true,
        messages: {
          success: ["Company created"],
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
        post '/companies', params: {
          name: "Third Company",
          configuration: {
            legal_entity_name: "Third Company Legal",
            logo: nil,
            start_date: '2021-01-01',
            end_date: '2022-01-01',
          }
        }, headers: @headers.deep_dup
        @company_data = JSON.parse(response.body)["data"]
      end
    end

    describe "GET #show" do
      it "returns correct response" do
        get "/companies/#{@company_data['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          data: @company_data,
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
        put "/companies/#{@company_data['id']}", params: {
          name: "Third Company New",
          configuration: {
            legal_entity_name: "Third Company Legal New",
            logo: nil,
            start_date: '2020-01-01',
            end_date: '2023-01-01',
          }
        }, headers: @headers.deep_dup

        actual_response = JSON.parse(response.body)
        expect(actual_response["data"]).to have_key "updated_at"

        expected_response = {
          data: {
            id: @company_data['id'],
            name: "Third Company New",
            configuration: {
              legal_entity_name: "Third Company Legal New",
              logo: '/logos/original/missing.png',
              start_date: '2020-01-01',
              end_date: '2023-01-01',
            },
            created_at: @company_data['created_at'],
            updated_at: actual_response["data"]["updated_at"],
            active: true
          },
          success: true,
          messages: {
            errors: [],
            errors_meta: {},
            success: ["Company updated"]
          }
        }.as_json

        expect(JSON.parse(response.body)).to eq expected_response
      end

    end
  end
end