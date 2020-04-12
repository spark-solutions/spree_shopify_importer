require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::Adjustments::Tax::BaseData, type: :service do
  subject { described_class.new(spree_line_item, shopify_tax_line, spree_order) }

  describe '#attributes' do
    let(:spree_order) { create(:order_with_line_items) }
    let(:spree_line_item) { spree_order.line_items.first }
    let(:shopify_tax_line) { create(:shopify_tax_line) }
    let(:spree_tax_rate) { create(:tax_rate, zone: spree_order.tax_zone, tax_category: spree_line_item.tax_category) }
    let(:result) do
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
      spree_tax_rate
    end

    it 'returns hash of tax adjustment attributes' do
      expect(subject.attributes).to eq result
    end
  end
end
