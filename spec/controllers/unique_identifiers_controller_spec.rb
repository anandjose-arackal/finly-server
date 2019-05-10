require 'rails_helper'

RSpec.describe UniqueIdentifiersController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #set" do
    it "returns http success" do
      get :set
      expect(response).to have_http_status(:success)
    end
  end

end
