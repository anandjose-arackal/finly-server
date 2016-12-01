require 'test_helper'

class AddAndRemoveTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @preference = @company.export_preferences.first
    debugger
    @admin = users(:admin)
    @manager = users(:manager)
    @export_field_params = {export: {export_field_id: ExportField.type_expense_category_name,
                                     name: "Named Category"
                                    }
                           }
  end

  test "admins creating a new expoert field" do
    create_field_op = Export::Field::Create.new(@admin, @export_field_params)
    assert_difference '@company.export_preferences.count', 1 do
      @result = create_field_op.run
    end
    @created_preference = @result.field
    assert @created_preference
    assert_equal "Named Category", @created_preference.name
    assert_equal ExportField.type_expense_category_name, @created_preference.export_field_id
  end

  test "non admins cannot create new export fields" do
    create_field_op = Export::Field::Create.new(@manager, @export_field_params)
    assert_no_difference '@company.export_preferences.count', 1 do
      begin
        @result = create_field_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
  end

  test "admins destroying a particular export field" do
    destroy_op = Export::Field::Destroy.new(@admin, id: @preference.id)
    assert_difference '@company.export_preferences.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not ExportPreference.exists?(@preference.id)
  end

  test "non admins cannot destroy an export field" do
    destroy_op = Export::Field::Destroy.new(@manager, {export_field_id: @preference.id})
    assert_no_difference '@company.export_preferences.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
    assert ExportPreference.exists?(@preference.id)
  end
end