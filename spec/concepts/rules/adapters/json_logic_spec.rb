require 'rails_helper'

describe 'Rules::Adapters::JsonLogic' do

  context '#as_json' do
    before do
      # Do nothing
    end

    context 'when rule is invalid' do

    end

    context 'when controlling field is provided' do
      context 'when controlling field is in header' do
        context 'when source field and value field are not in line items' do

          it 'should be true if values are matching the criteria' do
            rule = Rules::Builder['note'].eq_any(value: 'apple')
            json_logic = Rules::Adapters::JSONLogic.as_json(rule, model_klass: Invoice, controlling_field: 'narration')

            data = { form: { note: 'apple' } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_truthy

            data = { form: { note: 'orange' } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_falsey
          end

        end

        context 'when source field and value field are in the same line item' do

          it 'should be true if any line items values of source field and value fields are matching the criteria' do
            rule = Rules::Builder['line_items.description'].eq_any(value: 'apple')
            json_logic = Rules::Adapters::JSONLogic.as_json(rule, model_klass: Invoice, controlling_field: 'narration')

            data = { form: { line_items: [{ description: 'orange' }, { description: 'apple' }] } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_truthy

            data = { form: { line_items: [{ description: 'orange' }] } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_falsey
          end

        end
      end

      context 'when controlling field is in line item' do
        context 'when source field and value field are not in line items' do

          it 'should be true if values are matching the criteria' do
            rule = Rules::Builder['note'].eq_any(value: 'apple')
            json_logic = Rules::Adapters::JSONLogic.as_json(rule, model_klass: Invoice, controlling_field: 'credit_notes.name')

            data = { form: { note: 'apple' } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_truthy

            data = { form: { note: 'orange' } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_falsey
          end

        end

        context 'when source field and value field are in the different parent line item' do

          it 'should be true if any line items values of source field and value fields are matching the criteria' do
            rule = Rules::Builder['line_items.description'].eq_any(value: 'apple')
            json_logic = Rules::Adapters::JSONLogic.as_json(rule, model_klass: Invoice, controlling_field: 'credit_notes.name')

            data = {
              form: {
                line_items: [{ description: 'orange' }, { description: 'apple' }],
                credit_notes: [{ name: 'cake' }]
              }
            }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_truthy

            data = { form: { line_items: [{ description: 'orange' }] } }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_falsey
          end

        end

        context 'when source field and value field are in the same parent line item' do

          it 'should build the criteria against the row data' do
            rule = Rules::Builder['line_items.description'].eq_any(value: 'apple')
            json_logic = Rules::Adapters::JSONLogic.as_json(rule, model_klass: Invoice, controlling_field: 'line_items.name')

            expect(json_logic.dig("eq_any", 0, 'var')).to eq('row.description')

            data = {
              form: {
                line_items: [{ description: 'orange' }, { description: 'apple' }],
                credit_notes: [{ name: 'cake' }]
              },
              row: { description: 'apple' }
            }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_truthy

            data = {
              form: {
                line_items: [{ description: 'orange' }, { description: 'apple' }],
                credit_notes: [{ name: 'cake' }]
              },
              row: { description: 'orange' }
            }
            expect(JSONLogic.apply(json_logic.with_indifferent_access, data.with_indifferent_access)).to be_falsey
          end

        end
      end
    end

    context 'when controlling field is not provided' do
      context 'when source field and value field are not in line items' do

      end

      context 'when source field and value field are in the same line item' do

      end
    end

  end
end