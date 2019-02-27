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
          @headers = authentication_headers_for(:web)
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: @headers))
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
            expect(@device.client.class).to eq(UserDeviceBrowser)
          end

          it 'should create new UserDevice' do
            expect(@before_device_count + 1).to eq(UserDevice.count)
            # expect(@device.type_id).to eq(UserDeviceType.id_for(:browser))
          end

          it 'should marked the UserDevice as unverified' do
            expect(@device.status_id).to eq(UserDeviceStatus.id_for(:unverified))
            expect(@device.client).to_not be_nil
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
              allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: @headers))
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
            expect(@device3.client).to eq(@device.client)
          end

        end

        describe '> Existing UserDevice' do
          # Use Device1
          # Use DeviceBrowser1
          before(:all) do
            RSpec::Mocks.with_temporary_scope do
              @before_device2_count = UserDevice.count
              @before_device_browser2_count = UserDeviceBrowser.count
              allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: @headers))
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

    describe '> Incomplete Params' do
      describe '> New UserDeviceBrowser' do
        describe '> New UserDevice' do
          [
              :timestamp_s, :user_agent, :timezone, :fingerprint, :language,
              :browser, :browser_version, :browser_engine, :browser_engine_version,
              :os_name, :os_version,
              :screen_width, :screen_height, :color_depth, :is_mobile
          ].each do |item|
            describe "> Incomplete #{item}" do
              before(:all) do
                RSpec::Mocks.with_temporary_scope do
                  @before_device_count = UserDevice.count
                  @before_device_browser_count = UserDeviceBrowser.count
                  allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web, "#{item}": nil)))
                  @result = UserDevices::FindOrCreate.(@user1, {scope: ['web']})
                  @device = @result&.device
                end
              end

              it 'should return success' do
                expect(@result.success?).to eq(true)
              end

              it 'should create a new UserDevice with status as incomplete along with the respective message' do
                expect(@before_device_count + 1).to eq(UserDevice.count)
                expect(@device).to_not be_nil
                expect(@device.valid?).to eq(true)
                expect(@device.status_id).to eq(UserDeviceStatus.id_for(:incomplete))
                expect(@device.message).to_not be_nil
              end

              it 'should create a new UserDeviceBrowser with status as incomplete along with the respective message' do
                expect(@before_device_browser_count + 1).to eq(UserDeviceBrowser.count)
                expect(@device.client).to_not be_nil
                expect(@device.client.valid?).to eq(true)
                expect(@device.client.status_id).to eq(UserDeviceStatus.id_for(:incomplete))
                expect(@device.client.message).to_not be_nil
              end
            end
          end
        end
      end
      describe '> Existing UserDeviceBrowser' do
        # Create an existing UserDeviceBrowser
        before(:all) do
          RSpec::Mocks.with_temporary_scope do
            @user3 = create :em_user, company: @company

            @before_device_count = UserDevice.count
            @before_device_browser_count = UserDeviceBrowser.count
            headers = authentication_headers_for(:web)
            @fingerprint = JSON.parse(Base64.decode64(headers['X-Finly-RP']))['13']['7']
            allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: headers))
            @result = UserDevices::FindOrCreate.(@user1, {scope: ['web']})
            @existing_device = @result&.device
          end
        end

        it 'should created UserDevice and UserDeviceBrowser' do
          expect(@before_device_count + 1).to eq(UserDevice.count)
          expect(@before_device_browser_count + 1).to eq(UserDeviceBrowser.count)
          expect(@existing_device).to_not be_nil
          expect(@existing_device.client).to_not be_nil
        end

        # New user, the existing device properties
        describe '> New UserDevice' do
          [
              :timestamp_s, :user_agent, :timezone, :fingerprint, :language,
              :browser, :browser_version, :browser_engine, :browser_engine_version,
              :os_name, :os_version,
              :screen_width, :screen_height, :color_depth, :is_mobile
          ].each do |item|
            describe "> Incorrect #{item}"
            before(:all) do
              RSpec::Mocks.with_temporary_scope do
                @before_device_count = UserDevice.count
                @before_device_browser_count = UserDeviceBrowser.count
                allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web, fingerprint: @fingerprint, "#{item}": nil)))
                @result = UserDevices::FindOrCreate.(@user3, {scope: ['web']})
                @device = @result&.device
              end
            end

            it 'should succeed' do
              expect(@result.success?).to eq(true)
            end

            it 'should create UserDeviceBrowser with status as attribute mismatch' do
              expect(@before_device_browser_count + 1).to eq(UserDeviceBrowser.count)
              expect(@device.client).to_not be_nil
              expect(@device.client.status_id).to eq(UserDeviceStatus.id_for(:attribute_mismatch))
              expect(@device.client.message).to_not be_nil
            end

            it 'should create UserDevice with status as attribute mismatch' do
              expect(@before_device_count + 1).to eq(UserDevice.count)
              expect(@device).to_not be_nil
              expect(@device.status_id).to eq(UserDeviceStatus.id_for(:attribute_mismatch))
              expect(@device.message).to_not be_nil
            end
          end
        end

        # existing user, the existing device properties
        describe '> Existing UserDevice' do
          [
              :timestamp_s, :user_agent, :timezone, :fingerprint, :language,
              :browser, :browser_version, :browser_engine, :browser_engine_version,
              :os_name, :os_version,
              :screen_width, :screen_height, :color_depth, :is_mobile
          ].each do |item|
            describe "> Incorrect #{item}"
            before(:all) do
              RSpec::Mocks.with_temporary_scope do
                @before_device_count = UserDevice.count
                @before_device_browser_count = UserDeviceBrowser.count
                allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web, fingerprint: @fingerprint, "#{item}": nil)))
                @result = UserDevices::FindOrCreate.(@user1, {scope: ['web']})
                @device = @result&.device
              end
            end

            it 'should succeed' do
              expect(@result.success?).to eq(true)
            end

            it 'should create UserDeviceBrowser with status as attribute mismatch' do
              expect(@before_device_browser_count + 1).to eq(UserDeviceBrowser.count)
              expect(@device.client).to_not be_nil
              expect(@device.client.status_id).to eq(UserDeviceStatus.id_for(:attribute_mismatch))
              expect(@device.client.message).to_not be_nil
            end

            it 'should create UserDevice with status as attribute mismatch' do
              expect(@before_device_count + 1).to eq(UserDevice.count)
              expect(@device).to_not be_nil
              expect(@device.status_id).to eq(UserDeviceStatus.id_for(:attribute_mismatch))
              expect(@device.message).to_not be_nil
            end
          end
        end
      end
    end

    describe '> Nil User' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          @before_device_count = UserDevice.count
          @before_device_browser_count = UserDeviceBrowser.count
          allow(RequestStoreUtil).to receive(:current_request).and_return(double(headers: authentication_headers_for(:web)))
          @result = UserDevices::FindOrCreate.(nil, {scope: ['web']})
        end
      end

      it 'should not succeed' do
        expect(@result.success?).to eq(false)
        expect(@result.messages[:error]).to_not be_nil
        expect(@result.respond_to?(:device)).to eq(false)
      end

      it 'should not create a UserDevice' do
        expect(@before_device_count).to eq(UserDevice.count)
      end

      it 'should not create a new UserDeviceBrowser' do
        expect(@before_device_browser_count).to eq(UserDeviceBrowser.count)
      end
    end
  end

end
