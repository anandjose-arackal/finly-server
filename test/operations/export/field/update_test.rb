require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @preference = @company.export_preferences.first
    @admin = User.first
    @manager = User.find_by(email: 'manager0@finlytest.io')
  end

  test "admins can update an existing export field" do
    update_op = Export::Field::Update.new(@admin, {export: {export_field_id: @preference.id,
                                                            name: "Changed name."}
                                                  }
                                          )
    @preference = update_op.run
    assert @preference
    assert_equal "Changed name.", @preference.name
  end

  test "non admins cannot update export preferences" do
    update_op = Export::Field::Update.new(@manager, {export: {export_field_id: @preference.id,
                                                            name: "Changed name."}
                                                  }
                                          )
    begin
      @preference = update_op.run
    rescue
      @rescued = true
    end
    assert @rescued
  end
end