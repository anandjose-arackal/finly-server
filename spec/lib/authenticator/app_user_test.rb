require 'rails_helper'

RSpec.describe 'Authenticator::Processor::Application' do

  before :all do
    @password = 'FW1g$18j0t!k2'
    @company = create :company
    @user = create :em_user, company: @company, password: @password, password_confirmation: @password
  end

  describe '> Incomplete request' do
    describe '> Empty username' do
      it 'should not return user' do
        allow(Gatekeeper::Event).to receive(:call).and_return(double(success?: true))
        allow(UserSessions::Create).to receive(:call).and_return(double(success?: true))
        params = {password: @password, scope: ['web']}
        request = double({params: params})

        user = Authenticator::Processor.new(request).authenticate

        expect(user).to be_nil
      end
    end

    describe '> Empty password' do
      it 'should not return user' do
        allow(Gatekeeper::Event).to receive(:call).and_return(double(success?: true))
        allow(UserSessions::Create).to receive(:call).and_return(double(success?: true))

        params = {username: @user.email, scope: ['web']}
        request = double({params: params})

        user = Authenticator::Processor.new(request).authenticate

        expect(user).to be_nil
      end
    end

    describe '> No scope' do
      it 'should raise an error' do
        params = {username: @user.email, password: @password}
        request = double({params: params})
        expect {
          user = Authenticator::Processor.new(request).authenticate
        }.to raise_error
      end
    end
  end

  describe '> Correct request' do
    describe '> User not found' do
      it 'should not send a user back' do
        allow(Gatekeeper::Event).to receive(:call).and_return(double(success?: true))
        allow(UserSessions::Create).to receive(:call).and_return(double(success?: true))

        params = {username: 'dummy@email.com', password: 'testpassword@123!', scope: ['web']}
        request = double({params: params})
        user = Authenticator::Processor.new(request).authenticate

        expect(user).to be_nil
      end
    end

    describe '> Wrong password' do
      it 'should not send a user back' do
        allow(Gatekeeper::Event).to receive(:call).and_return(double(success?: true))
        allow(UserSessions::Create).to receive(:call).and_return(double(success?: true))

        params = {username: @user.email, password: 'testpassword@123!', scope: ['web']}
        request = double({params: params})
        user = Authenticator::Processor.new(request).authenticate

        expect(user).to be_nil
      end
    end

    describe '> Correct password' do
      it 'should send a user back' do
        allow(Gatekeeper::Event).to receive(:call).and_return(double(success?: true))
        allow(UserSessions::Create).to receive(:call).and_return(double(success?: true))

        params = {username: @user.email, password: @password, scope: ['web']}
        request = double({params: params})
        user = Authenticator::Processor.new(request).authenticate

        expect(user).to eq(@user)
      end
    end

  end

end