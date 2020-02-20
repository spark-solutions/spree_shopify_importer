require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Adjustments::TaxCreator, type: :service do
  subject { described_class.new(spree_line_item, shopify_tax_line, spree_order) }

  describe '#save!' do
    let(:spree_order) { create(:order_with_line_items) }
    let(:spree_line_item) { spree_order.line_items.first }
    let(:shopify_tax_line) { create(:shopify_tax_line) }
    let!(:spree_tax_rate) { create(:tax_rate, tax_category: spree_line_item.tax_category, zone: spree_order.tax_zone) }

    it 'creates tax adjustment' do
      expect { subject.create! }.to change(Spree::Adjustment, :count).by(1)
    end

    context 'sets an adjustment attributes' do
      let(:adjustment) { Spree::Adjustment.last }

      before { subject.create! }

      it 'label' do
        expect(adjustment.label).to eq shopify_tax_line.title
      end

      it 'amount' do
        expect(adjustment.amount).to eq shopify_tax_line.price
      end

      it 'state' do
        expect(adjustment).to be_closed
      end
    end

    context 'sets an adjustment associations' do
      let(:adjustment) { Spree::Adjustment.last }

      before { subject.create! }

      it 'order' do
        expect(adjustment.order).to eq spree_order
      end

      it 'adjustable' do
        expect(adjustment.adjustable).to eq spree_order
      end

      it 'source' do
        expect(adjustment.source).to eq spree_tax_rate
      end
    end
  end
end
