require 'test_helper'

class CompanyRegisterServiceTest < ActiveSupport::TestCase

  test "company name is required for registration" do
    reg = CompanyRegisterService.new("")
    reg.contact("a", "b", "c@d.com", 9986676713)
    reg.admin("test","a@b.com",99866767,'password')
    assert_not reg.register
    assert_not reg.errors.nil?

    reg.name = "Test"
    assert reg.register
  end

end
