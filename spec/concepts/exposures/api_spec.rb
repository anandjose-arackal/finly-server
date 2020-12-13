require 'rails_helper'

RSpec.describe Exposures::API do
  it 'raise NoMethodError when field not available in exposure or custom_fields' do
    invoice = create :invoice
    expect{
      invoice.to_exposure.check_method_missing
    }.to raise_error(NoMethodError)
  end

  it 'do not raise NoMethodError when field not available in exposure or custom_fields while rendering through liquid template' do
    invoice = create :invoice
    expect(invoice.to_exposure.template("{{record.check_method_missing}}")).to eq ""
  end

  
end