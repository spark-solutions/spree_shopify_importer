require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::LineItems::BaseData, type: :service do
  subject { described_class.new(shopify_line_item, shopify_order) }

  let(:shopify_line_item) { create(:shopify_line_item) }
  let(:shopify_order) { create(:shopify_order, line_items: [shopify_line_item]) }

  let(:spree_variant) { create(:variant) }
  let(:variant_data_feed) do
    create(:shopify_data_feed,
           shopify_object_id: shopify_line_item.variant_id,
           shopify_object_type: 'ShopifyAPI::Variant',
           spree_object: spree_variant)
  end

  before do
    variant_data_feed
  end

  describe '#line_item_attributes' do
    let(:result) do
      {
        quantity: shopify_line_item.quantity,
        price: shopify_line_item.price,
        currency: shopify_order.currency,
        adjustment_total: - shopify_line_item.total_discount,
        tax_category: spree_variant.tax_category
      }
    end

    it 'prepares hash of line item attributes' do
      expect(subject.line_item_attributes).to eq result
    end
  end

  describe '#variant' do
    context 'when variant is present in data_feed' do
      it 'returns a spree variant' do
        expect(subject.variant).to eq spree_variant
      end
    end

    context 'variant is missing', vcr: { cassette_name: 'shopify_import/data_parsers/line_item/missing_variant' } do
      let(:shopify_line_item) { create(:shopify_line_item, product_id: 11_055_169_028) }
      let(:spree_variant) { nil }

      before { authenticate_with_shopify }

      it 'returns a spree variant' do
        expect { subject.variant }.to raise_error(SpreeShopifyImporter::DataParsers::LineItems::VariantNotFound)
      end
    end
  end
end
