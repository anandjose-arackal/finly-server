require 'rails_helper'

RSpec.describe Exposures::API::Attribute do
  it 'CollectionProxy Association attribute should return Exposures::LazyList object' do
    invoice = create :invoice
    expect(
      invoice.to_exposure.line_items.class.name
    ).to eq 'Exposures::LazyList'
  end
  
end
