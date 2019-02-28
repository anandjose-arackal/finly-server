require 'rails_helper'

RSpec.describe 'UserSessions::Create' do

  describe '> Browser' do
    # Setup users
    before :all do
      @company = create :company
      @user1 = create :em_user, company: @company
      @user2 = create :em_user, company: @company
      @user_device_browser = create :user_device_browser
      @device = create :user_device, client: @user_device_browser
    end

    describe '> Failed' do
      describe '> With user' do
        before(:all) do

        end

        it 'should succeed' do

        end

        it 'should create new UserSession with status as failed, message cannot be blank' do

        end

        it 'should create new UserSessionEvent with the endpoint details' do

        end

        it 'should associated the respective UserDevice' do

        end
      end
      describe '> Without user' do
        it 'should succeed' do

        end

        it 'should create new UserSession with status as failed, message cannot be blank' do

        end

        it 'should create new UserSessionEvent with the endpoint details' do

        end

        it 'should not be associated the respective UserDevice' do

        end
      end
    end

    describe '> Blocked' do
      describe '> With user' do

      end
      describe '> Without user' do

      end
    end

    describe '> Authorized' do
      describe '> With user' do

      end
      describe '> Without user' do

      end
    end
  end

end