require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Adjustments::TaxCreator, type: :service do
  subject { described_class.new(spree_line_item, shopify_tax_line, spree_order) }

  let(:spree_line_item) { build_stubbed(:line_item) }
  let(:shopify_tax_line) { build_stubbed(:shopify_tax_line) }
  let(:spree_order) { create(:order_with_line_items) }

  describe '#create!' do
    let(:parser) { instance_double(SpreeShopifyImporter::DataParsers::Adjustments::Tax::BaseData) }
    let(:spree_tax_rate) { build_stubbed(:tax_rate) }
    let(:attributes) do
      {
        order: spree_order,
        adjustable: spree_order,
        label: shopify_tax_line.title,
        source: spree_tax_rate,
        amount: shopify_tax_line.price,
        state: :closed
      }
    end

    before do
      expect(SpreeShopifyImporter::DataParsers::Adjustments::Tax::BaseData).to receive(:new).with(spree_line_item, shopify_tax_line, spree_order).and_return(parser)
      expect(parser).to receive(:attributes).and_return(attributes)
    end

    it 'creates tax adjustment' do
      expect { subject.create! }.to change(Spree::Adjustment, :count).by(1)
    end

    it 'sets correct attributes' do
      adjustment = subject.create!

      expect(adjustment.label).to eq shopify_tax_line.title
      expect(adjustment.amount).to eq shopify_tax_line.price
      expect(adjustment).to be_closed
    end

    it 'sets correct associations' do
      adjustment = subject.create!

      expect(adjustment.order).to eq spree_order
      expect(adjustment.adjustable).to eq spree_order
      expect(adjustment.source).to eq spree_tax_rate
    end
  end
end
