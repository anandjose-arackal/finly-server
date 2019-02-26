require 'rails_helper'

RSpec.describe 'UserDevices::FindOrCreate' do

  # Setup users
  before :all do
    @company = create :company
    @user1 = create :em_user, company: @company
    @user2 = create :em_user, company: @company
  end

  describe '> Browser' do
    describe '> Correct Parameters' do

      # Create Device1
      # Create DeviceBrowser1
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @before_device_count = UserDevice.count
          @before_device_browser_count = UserDeviceBrowser.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web)))
          @result = UserDevices::FindOrCreate.(@user1, {scope: ['web']})
          @device = @result&.device
        end
      end

      describe '> New UserDeviceBrowser' do
        # Test Device1
        # DeviceBrowser1
        describe '> New UserDevice' do
          it 'should succeed' do
            expect(@result&.success?).to eq(true)
            expect(@device).to_not be_nil
            expect(@device.valid?).to eq(true)
          end

          it 'should not be incomplete' do
            expect(@device.incomplete?).to eq(false)
          end

          it 'should associated UserDevice with the user and company' do
            expect(@user1).to_not be_nil
            expect(@user1.company).to_not be_nil
            expect(@device.user).to eq(@user1)
            expect(@device.company).to eq(@user1.company)
          end

          it 'should create new UserDeviceBrowser' do
            expect(@before_device_browser_count + 1).to eq(UserDeviceBrowser.count)
            expect(@device.device_property.class).to eq(UserDeviceBrowser)
          end

          it 'should create new UserDevice' do
            expect(@before_device_count + 1).to eq(UserDevice.count)
            expect(@device.type_id).to eq(UserDeviceType.id_for(:browser))
          end

          it 'should marked the UserDevice as unverified' do
            expect(@device.status_id).to eq(UserDeviceStatus.id_for(:unverified))
            expect(@device.device_property).to_not be_nil
            expect(@device.incomplete?).to eq(false)
          end
        end
      end

      describe '> Existing UserDeviceBrowser' do

        describe '> New UserDevice' do
          # Create Device2
          # Use DeviceBrowser1
          before (:all) do
            RSpec::Mocks.with_temporary_scope do
              @before_device3_count = UserDevice.count
              @before_device3_browser_count = UserDeviceBrowser.count
              allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web)))
              @result3 = UserDevices::FindOrCreate.(@user2, {scope: ['web']})
              @device3 = @result3&.device
            end
          end

          it 'should succeed' do
            expect(@result3&.success?).to eq(true)
            expect(@device3).to_not be_nil
            expect(@device3.valid?).to eq(true)
          end

          it 'should associated UserDevice with the user and company' do
            expect(@user2).to_not be_nil
            expect(@user2.company).to_not be_nil
            expect(@device3.user).to eq(@user2)
            expect(@device3.company).to eq(@user2.company)
          end

          it 'should create a new UserDevice' do
            expect(@before_device3_count + 1).to eq(UserDevice.count)
          end

          it 'should not create a new UserDeviceBrowser' do
            expect(@before_device3_browser_count).to eq(UserDeviceBrowser.count)
          end

          it 'should attach existing UserDeviceBrowser to UserDevice' do
            expect(@device3.device_property).to eq(@device.device_property)
          end

        end

        describe '> Existing UserDevice' do
          # Use Device1
          # Use DeviceBrowser1
          before(:all) do
            RSpec::Mocks.with_temporary_scope do
              @before_device2_count = UserDevice.count
              @before_device_browser2_count = UserDeviceBrowser.count
              allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web)))
              @result2 = UserDevices::FindOrCreate.(@user1, {scope: ['web']})
              @device2 = @result2&.device
            end
          end

          it 'should succeed' do
            expect(@result2&.success?).to eq(true)
            expect(@device2).to_not be_nil
            expect(@device2.valid?).to eq(true)
          end

          it 'should associated UserDevice with the user and company' do
            expect(@user1).to_not be_nil
            expect(@user1.company).to_not be_nil
            expect(@device2.user).to eq(@user1)
            expect(@device2.company).to eq(@user1.company)
          end

          it 'should not create new UserDevice' do
            expect(@device).to eq(@device2)
            expect(@before_device2_count).to eq(UserDevice.count)
          end

          it 'should not create new UserDeviceBrowser' do
            expect(@before_device_browser2_count).to eq(UserDeviceBrowser.count)
          end

        end
      end
    end
  end

end
