require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe Masters::RecordsController, type: :request do
  before :all do
    @doorkeeper_application = create :doorkeeper_application
    @company_group1 = create :company_group
    @company1 = create :company, group: @company_group1
    @user1 = create :vp_admin_user, company: @company1, mobile_number: generate(:user_mobile_number), email: generate(:finly_user_email), finly_id: 'test1'
    @user_profile1 = create :user_profile, user: @user1
    # nosqli - These are TDD test cases that mock behavior for unit testing, these are not real credentials that work in Prod
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
    @headers['CONTENT_TYPE'] = "application/json"
    @headers['accept'] = "application/json"

    post '/masters', params: JSON.dump({
      name: "Projects",
      master_key: "projects",
      entities: [
        {
          "entity_type": "text",
          "entity_key": "field_1",
          "label": "Name",
          "primary_key": true,
          "unique": true,
          "required": true,
          "minimum": 4,
          "maximum": 15
        },
        {
          "entity_type": "large_text",
          "entity_key": "field_2",
          "label": "Long Description",
          "minimum": 10,
          "maximum": 20
        },
        {
          "entity_type": "integer",
          "entity_key": "field_3",
          "label": "Count",
          "min_value": 100,
          "max_value": 200
        },
        {
          "entity_type": "decimal",
          "entity_key": "field_4",
          "label": "Amount",
          "min_value": 100,
          "max_value": 200
        },
      ]
    }), headers: @headers.deep_dup
  end

  describe "GET #index" do
    it "returns http 200" do
      get '/masters/projects/records', headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    it "returns http 200" do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "Test",
      }), headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end

    it 'return http 422 with invalid data' do
      post '/masters/projects/records', params: JSON.dump({}), headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it 'returns correct data on successful create' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "Test",
        field_2: "Large Text goes here",
        field_3: "150",
        field_4: "175",
      }), headers: @headers.deep_dup

      actual_response = JSON.parse(response.body)

      expect(actual_response).to have_key "data"
      expect(actual_response["data"]).to have_key "id"
      expect(actual_response["data"]).to have_key "created_at"
      expect(actual_response["data"]).to have_key "updated_at"

      expected_response = {
        data: {
          id: actual_response["data"]["id"],
          display_name: "Test",
          field_1: "Test",
          field_2: "Large Text goes here",
          field_3: "150",
          field_4: "175",
          created_at: actual_response["data"]["created_at"],
          updated_at: actual_response["data"]["updated_at"],
        },
        success: true,
        messages: {
          success: ["Record Created"],
          errors: [],
          errors_meta: {}
        }
      }.as_json
      expect(actual_response).to eq expected_response
    end

    it 'return error with invalid data: Text entity - required' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "",
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            "Field 1 can't be blank"
          ],
          errors_meta: {
            "field_1": [
              "can't be blank"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Text entity - unique' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "project1",
      }), headers: @headers.deep_dup

      # try to create another record with same field_1
      post '/masters/projects/records', params: JSON.dump({
        field_1: "project1",
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            "Field 1 has already been taken"
          ],
          errors_meta: {
            "field_1": [
              "has already been taken"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Text entity - minimum' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "abc",
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 1 is too short (minimum is 4 characters)'
          ],
          errors_meta: {
            "field_1": [
              "is too short (minimum is 4 characters)"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Text entity - maximum' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "more than fifteen characters",
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 1 is too long (maximum is 15 characters)'
          ],
          errors_meta: {
            "field_1": [
              "is too long (maximum is 15 characters)"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: LargeText entity - minimum' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_2: "lssthan10"
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 2 is too short (minimum is 10 characters)'
          ],
          errors_meta: {
            "field_2": [
              "is too short (minimum is 10 characters)"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: LargeText entity - maximum' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_2: "more than twenty characters"
        }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 2 is too long (maximum is 20 characters)'
          ],
          errors_meta: {
            "field_2": [
              "is too long (maximum is 20 characters)"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Integer entity - min_value' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_3: 50
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 3 must be greater than or equal to 100'
          ],
          errors_meta: {
            "field_3": [
              "must be greater than or equal to 100"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Integer entity - max_value' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_3: 250
        }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 3 must be less than or equal to 200'
          ],
          errors_meta: {
            "field_3": [
              "must be less than or equal to 200"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Decimal entity - min_value' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_4: 50
      }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 4 must be greater than or equal to 100'
          ],
          errors_meta: {
            "field_4": [
              "must be greater than or equal to 100"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error with invalid data: Decimal entity - max_value' do
      post '/masters/projects/records', params: JSON.dump({
        field_1: "test",
        field_4: 250
        }), headers: @headers.deep_dup

      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Field 4 must be less than or equal to 200'
          ],
          errors_meta: {
            "field_4": [
              "must be less than or equal to 200"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

  end


  describe "GET #show, PUT #update and DELETE #destroy" do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        post '/masters/projects/records', params: JSON.dump({
          field_1: "Test",
          field_2: "Large Text goes here",
          field_3: "150",
          field_4: "175",
        }), headers: @headers.deep_dup
        @record_data = JSON.parse(response.body)["data"]
      end
    end

    describe "GET #show" do
      it "returns correct response" do
        get "/masters/projects/records/#{@record_data['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          data: {
            id: @record_data["id"],
            display_name: "Test",
            field_1: "Test",
            field_2: "Large Text goes here",
            field_3: "150",
            field_4: "175",
            created_at: @record_data["created_at"],
            updated_at: @record_data["updated_at"],
          },
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
        put "/masters/projects/records/#{@record_data['id']}", params: JSON.dump({
          field_1: "Test Update",
          field_2: "Large Text update",
          field_3: "160",
          field_4: "185",
        }), headers: @headers.deep_dup

        actual_response = JSON.parse(response.body)
        expect(actual_response["data"]).to have_key "updated_at"

        expected_response = {
          data: {
            id: @record_data["id"],
            display_name: "Test Update",
            field_1: "Test Update",
            field_2: "Large Text update",
            field_3: "160",
            field_4: "185",
            created_at: @record_data["created_at"],
            updated_at: actual_response["data"]["updated_at"],
          },
          success: true,
          messages: {
            errors: [],
            errors_meta: {},
            success: ["Record Updated"]
          }
        }.as_json

        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    describe "DELETE #destroy" do
      it "deletes record successfully" do
        delete "/masters/projects/records/#{@record_data['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)
      end

      it "returns 404 after delete" do
        get "/masters/projects/records/#{@record_data['id']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)
      end
    end
  end
end