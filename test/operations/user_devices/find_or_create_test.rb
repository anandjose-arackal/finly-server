require 'minitest_setup'

class UserDevices::FindOrCreateTest < ActiveSupport::TestCase
  MinitestSetup.run(self)
  include RequestHelper

  describe 'UserDevices::FindOrCreate' do
    describe 'Browser' do
      describe 'CorrectParameters' do
        before(:all) do
          headers = authentication_headers_for(:web)
          decoded_headers = JSON.parse(Base64.decode64(headers['X-Finly-RP']))
          config = UserDevice::DEVICES[:browser]
          fingerprint = decoded_headers[config[:device_key].to_s][UserDeviceBrowser.obfuscation_map[:fingerprint]]
          assert_not_nil fingerprint
          return_val = mock(headers: headers)
          RequestStoreUtil.stubs(current_request: return_val)
        end

        describe 'New' do

          before(:all) do
            @before_device_count = UserDevice.count
            @before_device_browser_count = UserDeviceBrowser.count
            @result = UserDevices::FindOrCreate.({scope: ['web']})
            @device = @result&.device
          end

          it 'should succeed' do
            assert @result&.success?
            assert_not_nil @device
            assert @device.valid?
          end

          it 'should be of type browser' do
            assert_equal @device.type_id, UserDeviceType.id_for(:browser)
          end

          it 'should create new @device' do
            assert_equal (@before_device_count + 1), UserDevice.count
            assert_equal (@before_device_browser_count + 1), UserDeviceBrowser.count
          end

          it 'should be marked as unverified' do
            assert_equal @device.status_id, UserDeviceStatus.id_for(:unverified)
            assert_not_nil @device.device_property
            assert_not @device.incomplete?
          end

          describe 'Existing' do
            before(:all) do
              @before_device_2_count = UserDevice.count
              @before_device_browser_2_count = UserDeviceBrowser.count
              @result_2 = UserDevices::FindOrCreate.({scope: ['web']})
              @device_2 = @result&.device
            end

            it 'should succeed' do
              assert @result_2&.success?
              assert_not_nil @device_2
              assert @device_2.valid?
            end

            it 'should not create new @device' do
              assert_equal (@before_device_count), UserDevice.count
              assert_equal (@before_device_browser_count), UserDeviceBrowser.count
            end

            it 'should be the same as the previously created device' do
              assert_equal @device, @device_2
              assert_equal @before_device_browser_count, @before_device_browser_2_count
            end
          end

        end

      end
    end
  end

end