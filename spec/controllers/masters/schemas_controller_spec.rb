require 'rails_helper'
require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe Masters::SchemasController, type: :request do
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
  end

  describe "GET #index" do
    it "returns http 200" do
      get '/index/master_schemas.json', headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    it "return http 200" do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(200)
    end

    it 'return http 422 with invalid data' do
      post '/masters', params: {}, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
    end

    it 'returns correct data on successful create' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0
          }
        ]
      }, headers: @headers.deep_dup

      actual_response = JSON.parse(response.body)
      expect(actual_response).to have_key "data"
      expect(actual_response["data"]).to have_key "id"
      expect(actual_response["data"]).to have_key "created_at"
      expect(actual_response["data"]).to have_key "updated_at"
      expect(actual_response["data"]).to have_key "entities"

      expected_response = {
        data: {
          id: actual_response["data"]["id"],
          name: "Projects",
          master_key: "projects",
          has_nesting: false,
          entities: [
            {
              "id": actual_response["data"]["entities"][0]['id'],
              "entity_type": "text",
              "entity_key": "field_1",
              "label": "Name",
              "primary_key": true,
              "unique": true,
              "hint": "Type name",
              "position": "0",
              "required": false,
              "options": {
                "maximum": 255,
                "minimum": 0
              }
            }
          ],
          system_master: false,
          active: true,
          created_at: actual_response["data"]["created_at"],
          updated_at: actual_response["data"]["updated_at"],
        },
        success: true,
        messages: {
          success: ["Master Schema Created"],
          errors: [],
          errors_meta: {}
        }
      }.as_json
      expect(actual_response).to eq expected_response
    end

    it 'return error on invalid data for: Invalid entity_key' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "some_key",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > entity key is not valid'
          ],
          errors_meta: {
            "entities.entity_key": [
              "is not valid"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Empty label' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            "Entities > label can't be blank"
          ],
          errors_meta: {
            "entities.label": [
              "can't be blank"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Primary Key Required' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "unique": true,
            "hint": "Type name",
            position: 0,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Primary key is not set'
          ],
          errors_meta: {
            "primary_key": [
              "is not set"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Text entity - minimum >= 0' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "minimum": -1,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > minimum has to be greater than or equal to 0'
          ],
          errors_meta: {
            "entities.minimum": [
              "has to be greater than or equal to 0"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Text entity - maximum <= 255' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "maximum": 1000,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > maximum has to be less than or equal to 255'
          ],
          errors_meta: {
            "entities.maximum": [
              "has to be less than or equal to 255"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Text entity - maximum >= minimum' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "minimum": 200,
            "maximum": 0,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > minimum has to be less than or equal to maximum'
          ],
          errors_meta: {
            "entities.minimum": [
              "has to be less than or equal to maximum"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end


    it 'return error on invalid data for: Sequence entity - prefix required' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0
          },
          {
            "entity_type": "sequence",
            "entity_key": "field_2",
            "label": "Code",
            "hint": "Type Code",
            position: 1
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > prefix cannot be blank'
          ],
          errors_meta: {
            "entities.prefix": [
              "cannot be blank"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Sequence min_length >= 0' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0
          },
          {
            "entity_type": "sequence",
            "entity_key": "field_2",
            "label": "Code",
            "hint": "Type Code",
            position: 1,
            prefix: 'TST',
            min_length: -1
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > min length has to be greater than or equal to 0'
          ],
          errors_meta: {
            "entities.min_length": [
              "has to be greater than or equal to 0"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Sequence min_length <= 10' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0
          },
          {
            "entity_type": "sequence",
            "entity_key": "field_2",
            "label": "Code",
            "hint": "Type Code",
            position: 1,
            prefix: 'TST',
            min_length: 11
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > min length has to be less than or equal to 10'
          ],
          errors_meta: {
            "entities.min_length": [
              "has to be less than or equal to 10"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: LargeText entity - minimum >= 0' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "large_text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "minimum": -1,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)
      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > minimum has to be greater than or equal to 0'
          ],
          errors_meta: {
            "entities.minimum": [
              "has to be greater than or equal to 0"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: LargeText entity - maximum <= 65535' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "large_text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "maximum": 10000000,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > maximum has to be less than or equal to 65535'
          ],
          errors_meta: {
            "entities.maximum": [
              "has to be less than or equal to 65535"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: LargeText entity - maximum >= minimum' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "large_text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
            "minimum": 20000,
            "maximum": 0,
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > minimum has to be less than or equal to maximum'
          ],
          errors_meta: {
            "entities.minimum": [
              "has to be less than or equal to maximum"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Integer entity - max_value >= min_value' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "large_text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
          },
          {
            "entity_type": "integer",
            "entity_key": "field_2",
            "label": "Count",
            "hint": "Type COUNT",
            position: 1,
            min_value: 100,
            max_value: 1
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > min value has to be less than or equal to max_value'
          ],
          errors_meta: {
            "entities.min_value": [
              "has to be less than or equal to max_value"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end

    it 'return error on invalid data for: Decimal entity - max_value >= min_value' do
      post '/masters', params: {
        name: "Projects",
        master_key: "projects",
        entities: [
          {
            "entity_type": "large_text",
            "entity_key": "field_1",
            "label": "Name",
            "primary_key": true,
            "unique": true,
            "hint": "Type name",
            position: 0,
          },
          {
            "entity_type": "decimal",
            "entity_key": "field_2",
            "label": "Count",
            "hint": "Type COUNT",
            position: 1,
            min_value: 100,
            max_value: 1
          }
        ]
      }, headers: @headers.deep_dup
      expect(response).to have_http_status(422)

      expected_response = {
        success: false,
        messages: {
          success: [],
          errors: [
            'Entities > min value has to be less than or equal to max_value'
          ],
          errors_meta: {
            "entities.min_value": [
              "has to be less than or equal to max_value"
            ]
          }
        }
      }.as_json
      expect(JSON.parse(response.body)).to eq expected_response
    end


  end

  describe "GET #show and PUT #update" do
    before :all do
      RSpec::Mocks.with_temporary_scope do
        post '/masters', params: {
          name: "Projects",
          master_key: "projects",
          entities: [
            {
              "entity_type": "text",
              "entity_key": "field_1",
              "label": "Name",
              "primary_key": true,
              "unique": true,
              "hint": "Type name",
              position: 0
            }
          ]
        }, headers: @headers.deep_dup
        @master_schema_data = JSON.parse(response.body)["data"]
      end
    end

    describe "GET #show" do
      it "returns correct response" do
        get "/masters/#{@master_schema_data['master_key']}", headers: @headers.deep_dup
        expect(response).to have_http_status(200)

        expected_response = {
          data: @master_schema_data,
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
        put "/masters/#{@master_schema_data['master_key']}", params: {
          name: "Projects 2",
          master_key: "projects",
          entities: [
            {
              id: @master_schema_data["entities"][0]['id'],
              "entity_type": "text",
              "entity_key": "field_1",
              "label": "Name",
              "primary_key": true,
              "unique": true,
              "hint": "Type name",
              position: 0
            }
          ]
        }, headers: @headers.deep_dup

        actual_response = JSON.parse(response.body)
        expect(actual_response["data"]).to have_key "updated_at"

        expected_response = {
          data: {
            id: @master_schema_data["id"],
            name: "Projects 2",
            master_key: "projects",
            has_nesting: false,
            entities: [
              {
                "id": @master_schema_data["entities"][0]['id'],
                "entity_type": "text",
                "entity_key": "field_1",
                "label": "Name",
                "primary_key": true,
                "unique": true,
                "hint": "Type name",
                "position": "0",
                "required": false,
                "options": {
                  "maximum": 255,
                  "minimum": 0
                }
              }
            ],
            system_master: false,
            active: true,
            created_at: @master_schema_data["created_at"],
            updated_at: actual_response["data"]["updated_at"],
          },
          success: true,
          messages: {
            success: ["Master Schema Updated"],
            errors: [],
            errors_meta: {}
          }
        }.as_json

        expect(JSON.parse(response.body)).to eq expected_response
      end

    end
  end
end