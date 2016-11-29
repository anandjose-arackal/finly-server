require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @preference = @company.export_preferences.first
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @update_params = {export: {export_field_id: ExportField.type_employee_name,
                               name: "Changed Name"
                              },
                      id: @preference.id
                     }
  end

  test "admins can update an existing export field" do
    update_op = Company::ExportPreferences::Update.new(@admin, @update_params)
    @result = update_op.run
    assert @result.success?
    assert_equal "Changed Name", @result.field.name
  end

  test "non admins cannot update export preferences" do
    original_name = @preference.name
    update_op =  Company::ExportPreferences::Update.new(@manager, @update_params)
    begin
      @result = update_op.run
    rescue NotAuthorizedException
      @rescued = true
    end
    assert @rescued
    assert_equal original_name, @preference.name
  end
end