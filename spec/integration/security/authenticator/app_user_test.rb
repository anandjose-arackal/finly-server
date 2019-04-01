RSpec.describe 'Authenticator::Processor::Application' do

  before :all do
    @company = create :company
    @user = create :user, company: @company
  end

  describe '> Incomplete request' do
    describe '> Empty username' do

    end

    describe '> Empty password' do

    end

    describe '> No scope' do

    end
  end

  describe '> Correct request' do
    describe '> User not found' do

    end

    describe '> Correct password' do

    end

    describe '> Wrong password' do

    end
  end

  # Admin User
  # Admin Bypass

end