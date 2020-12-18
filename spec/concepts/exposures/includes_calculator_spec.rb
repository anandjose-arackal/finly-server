require 'rails_helper'

RSpec.describe Exposures::IncludesCalculator do
  context 'calculate includes for single record' do
    it 'for expression with no exposure fields' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.invoice_id }}'], 'record')
      expected = {}
      expect(includes).to eq expected
    end
    it 'for expression with exposure field' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.vendor.name }}'], 'record')
      expected = { vendor: {} }
      expect(includes).to eq expected
    end
    it 'for expression with exposure field duplicates merged' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.vendor.name }} {{record.vendor.policy}}'], 'record')
      expected = { vendor: { policy: {} } }
      expect(includes).to eq expected
    end

    it 'for expression with nested exposure field' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.vendor.created_by.name }}'], 'record')
      expected = { vendor: { created_by: {} } }
      expect(includes).to eq expected
    end

    it 'for expression with includes non specified in exposure' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.invoice_type }}'], 'record')
      expected = { invoice_type: {} }
      expect(includes).to eq expected
    end

    it 'for expression with renamed record attribute' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.billing_location }}'], 'record')
      expected = { location: {} }
      expect(includes).to eq expected
    end

    it 'for expression with non-exposure attributes with includes' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.gross_amount_value }}'], 'record')
      expected = { gross_amount: {} }
      expect(includes).to eq expected
    end

    it 'for expression with non-exposure attributes with multiple includes' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.paid_amount_value }}'], 'record')
      expected = { balance_due: {}, successful_payments: { amount: {} } }
      expect(includes).to eq expected
    end

    it 'for template with multiple fields' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.base_amount }} {{ record.total_invoice_amount }}'], 'record')
      expected = { invoice_items: {}, amount: {}, original_amount: {}, gross_amount: {}, tax_amount: {} }
      expect(includes).to eq expected
    end

    it 'for template with if condition' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% if record.company %}{{ record.vendor }}{% elsif record.gstin_location %}{{ record.vendor_location }}{% else %}{{ record.department }}{% endif %}'], 'record')
      expected = { company: {}, vendor: {}, gstin_location: {}, vendor_location: {}, department: {} }
      expect(includes).to eq expected
    end

    it 'for template with unless condition' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% unless record.company %}{{ record.vendor }}{% else %}{{ record.department }}{% endunless %}'], 'record')
      expected = { company: {}, vendor: {}, department: {} }
      expect(includes).to eq expected
    end

    it 'for template with forloop' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% for item in record.line_items %}{{ item.tax_rate }}{% else %}{{item.billable_amount}}{% endfor %}'], 'record')
      expected = { invoice_items: { tax_rate: {}, billable_amount: {} } }
      expect(includes).to eq expected
    end

    it 'for template with assign expression' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% assign data = record.company.name %}'], 'record')
      expected = { company:  {} }
      expect(includes).to eq expected
    end

    it 'for template with case/when expression' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% case record.invoice_type %}{% when record.tds_slab %}{{record.department}}{% else %}{{record.cost_center}}{% endcase %}'], 'record')
      expected = { invoice_type: {}, tds_slab: {}, department: {}, cost_center: {} }
      expect(includes).to eq expected
    end

    it 'for template with expression with filter' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{{ record.company.name | append: record.gstin_location.vendor.name }}'], 'record')
      expected = { company: {}, gstin_location: { vendor: {} } }
      expect(includes).to eq expected
    end

    it 'for template with expression with cycle' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% cycle record.gstin_location, record.vendor_location %}'], 'record')
      expected = { gstin_location: {}, vendor_location: {} }
      expect(includes).to eq expected
    end
  end

  context 'calculate includes for multiple records' do
    it 'for template with forloop' do
      includes = Exposures::IncludesCalculator.call(Invoice, ['{% for item in records %}{{ item.vendor.name }}{% endfor %}'], 'records')
      expected = { vendor: {} }
      expect(includes).to eq expected
    end
  end
end
