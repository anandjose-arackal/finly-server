require 'rails_helper'

RSpec.describe Exposures::Model::Exposable do
  it '#exposure_class' do
    expect(Invoice.exposure_class.name).to eq 'InvoiceExposure'
  end

  it '#to_exposures' do
    expect(Invoice.all.to_exposures.class.name).to eq 'Exposures::LazyList'
  end
end