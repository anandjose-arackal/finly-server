# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(TRUE), not null
#


require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  test "cannot create company without a name" do
    company = Company.new
    assert_not company.valid?

    company.name = "Name"
    assert company.valid?
  end

  test "valid company" do
    company = Company.new(name: "Test company")
    assert company.valid?
    assert company.save
  end

  test "creating a company should create its configurations" do
    company = Company.new(name: "Test company")
    assert company.valid?
    assert company.save

    company.reload
    assert company.configuration.present?
  end

end
