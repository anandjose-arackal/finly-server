# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  name             :string(255)
#  number           :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contactable_id   :integer
#  contactable_type :string(255)
#  designation      :string(255)
#


require 'test_helper'

class ContactTest < ActiveSupport::TestCase

  test "cannot create a contact with all fields nil" do
    contact = Contact.new
    assert_not contact.valid?
    assert_not contact.save
  end

  test "contact can either contact or email nil but not both" do
    contact = Company.first.contacts.build(name: "Test", designation: "Te")
    assert_not contact.valid?

    contact.number = "9986676"
    assert contact.valid?

    contact.number = nil
    assert_not contact.valid?

    contact.email = "a@b.com"
    assert contact.valid?
  end

  test "valid contact" do
    contact = Company.first.contacts.build(name: "Test", designation: "Te", number: "123456", email: "a@b.com")
    contact.valid?
  end

  test "contact accepts only valid email address" do
    contact = Company.first.contacts.build(email: "test")
    assert_not contact.valid?

    contact.email = "a@b.com"
    assert contact.valid?
  end

end
