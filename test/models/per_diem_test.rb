# == Schema Information
#
# Table name: per_diems
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  rate_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  configurable_id   :integer
#  configurable_type :string(255)
#

require 'test_helper'

class PerDiemTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @policy = Policy.first
    @valid_attributes = {name: "Something",
                         rate_attributes: {value: "500", currency_id: 1},
                        }
    @invalid_attributes = {name: "",
                           rate_attributes: {value: "500", currency_id: 1},
                          }

    @per_diem = @company.per_diems.create(@valid_attributes)
  end


  test "successfull creation of per diem with valid attributes" do
    # on a company level
    assert_difference 'PerDiem.count', 1 do
      @per_diem = @company.per_diems.build(@valid_attributes)
      @result = @per_diem.save
    end

    assert @result
    assert_equal @company, @per_diem.configurable

    # on a policy level
    assert_difference 'PerDiem.count', 1 do
      @per_diem = @policy.per_diems.build(@valid_attributes)
      @result = @per_diem.save
    end

    assert @result
    assert_equal @policy, @per_diem.configurable

  end

  test "unsuccessful creation of per diem with invalid parameters" do

    # invalid amount
    assert_no_difference 'PerDiem.count' do
      @per_diem = @company.per_diems.build(@invalid_attributes)
      @result = @per_diem.save
    end

    assert_not @result
    puts @per_diem.errors.full_messages.to_sentence
    assert_not PerDiem.exists?(@per_diem.id)

    # invalid name
    # changing the amount to a negative amount
    @invalid_attributes[:name] = "Something"
    @invalid_attributes[:rate_attributes][:value] = "-500"

    assert_no_difference 'PerDiem.count' do
      @per_diem = @company.per_diems.build(@invalid_attributes)
      @result = @per_diem.save
    end

    assert_not @result
    puts @per_diem.errors.full_messages.to_sentence
    assert_not PerDiem.exists?(@per_diem.id)

    # invalid currency ID
    # changing the currency ID to a one different from what we intended - this should throw an exception
    @invalid_attributes[:rate_attributes][:value] = "500"
    @invalid_attributes[:rate_attributes][:currency_id] = "3"

    assert_no_difference 'PerDiem.count' do
      begin
        @per_diem = @company.per_diems.build(@invalid_attributes)
        @result = @per_diem.save
      rescue
        @rescued = true
      end
    end
    assert @rescued
  end

  test "update a particular per diem with valid parameters" do
    # valid parameters for amount change
    @valid_attributes[:rate_attributes][:value] = "200"

    assert_no_difference 'PerDiem.count', 1 do
      @per_diem.update(@valid_attributes)
    end
    assert_equal 200, @per_diem.rate_value
    assert_equal "Something", @per_diem.name

    # valid parameters for name change
    @valid_attributes[:name] = "Suuuup"

    assert_no_difference 'PerDiem.count', 1 do
      @per_diem.update(@valid_attributes)
    end
    assert_equal 200, @per_diem.rate_value
    assert_equal "Suuuup", @per_diem.name

  end

  test "cannot update a particular per diem with invalid parameters" do
    @valid_attributes[:rate_attributes][:value] = "-200"
    # @valid_attributes[:rate_attributes][:id] = @per_diem.id

    assert_no_difference 'PerDiem.count', 1 do
      @result = @per_diem.update(@valid_attributes)
    end

    assert_not @result
    assert_not_empty @per_diem.errors.full_messages
    assert_equal 500, @per_diem.reload.rate_value
    assert_equal "Something", @per_diem.name
  end

end
