require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe ExportTemplatesController, type: :request do
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

  describe "GET #index" do
    it "returns http 200" do
      get '/export_templates/', headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    it "returns http 200" do
      post '/export_templates/', params: {
        name: 'Template name',
        description: 'Template description',
        export_format: 'csv',
        resource: 'invoices',
        template: '{"columns":[{"label":"ID", "value": "{{record.id}}"}]}',
        query: {},
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end

    it "returns http 422 with invalid export_format" do
      post '/export_templates/', params: {
        name: 'Template name',
        description: 'Template description',
        export_format: 'invalid',
        resource: 'invoices',
        template: '{"columns":[{"label":"ID", "value": "{{record.id}}"}]}',
        query: {},
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it "returns http 422 with invalid resource" do
      post '/export_templates/', params: {
        name: 'Template name',
        description: 'Template description',
        export_format: 'csv',
        resource: 'invalid',
        template: '{"columns":[{"label":"ID", "value": "{{record.id}}"}]}',
        query: {},
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it "returns http 422 with empty template" do
      post '/export_templates/', params: {
        name: 'Template name',
        description: 'Template description',
        export_format: 'csv',
        resource: 'invoices',
        template: '',
        query: {},
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end
  end

  describe "GET #show and PUT #update" do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        post '/export_templates/', params: {
          name: 'Template name',
          description: 'Template description',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID", "value": "{{record.id}}"}]}',
          query: {"a": "b"},
          role_mappings: [{
            user_role_id: 1
          }]
        }, headers: @headers.deep_dup
        @template = JSON.parse(response.body)["result"]
      end
    end

    describe "GET #show" do
      it "returns correct response" do
        get "/export_templates/#{@template['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          id: @template['id'],
          name: 'Template name',
          description: 'Template description',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID", "value": "{{record.id}}"}]}',
          query: {a: "b"},
          created_by: @user1.name,
          personal: true,
          active: true,
          user_roles: [{
            id: 1,
            name: 'admin'
          }],
          created_at: @template["created_at"],
          updated_at: @template["updated_at"],
        }.as_json
        expect(JSON.parse(response.body)['result']).to eq expected_response
      end
    end

    describe "PUT #update" do
      it "returns correct response" do
        sleep 1
        puts "/export_templates/#{@template['id']}"
        put "/export_templates/#{@template['id']}", params: {
          name: 'Template name Update',
          description: 'Template description update',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID Update", "value": "{{record.id}}"}]}',
          query: nil,
          role_mappings: []
        }, headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          id: @template['id'],
          name: 'Template name Update',
          description: 'Template description update',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID Update", "value": "{{record.id}}"}]}',
          query: nil,
          created_by: @user1.name,
          personal: true,
          active: true,
          user_roles: [],
          created_at: @template["created_at"],
          updated_at: JSON.parse(response.body)["result"]["updated_at"],
        }.as_json
        expect(JSON.parse(response.body)['result']).to eq expected_response
      end

      it "updates role_mappings correctly" do
        put "/export_templates/#{@template['id']}", params: {
          name: 'Template name Update',
          description: 'Template description update',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID Update", "value": "{{record.id}}"}]}',
          query: nil,
          role_mappings: [{
            user_role_id: 2
          },{
            user_role_id: 3
          }]
        }, headers: @headers.deep_dup

        expected_response = {
          id: @template['id'],
          name: 'Template name Update',
          description: 'Template description update',
          export_format: 'csv',
          resource: 'invoices',
          template: '{"columns":[{"label":"ID Update", "value": "{{record.id}}"}]}',
          query: nil,
          created_by: @user1.name,
          personal: true,
          active: true,
          user_roles: [{
            id: 2,
            name: 'finance_manager'
          },{
            id: 3,
            name: 'manager'
          }],
          created_at: @template["created_at"],
          updated_at: JSON.parse(response.body)["result"]["updated_at"],
        }.as_json
        expect(JSON.parse(response.body)['result']).to eq expected_response
      end
    end
  end
end
