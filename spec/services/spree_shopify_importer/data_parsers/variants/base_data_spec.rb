require 'spec_helper'

RSpec.describe SpreeShopifyImporter::DataParsers::Variants::BaseData, type: :service do
  let(:spree_product) { create(:product) }
  let(:shopify_variant) { create(:shopify_variant) }
  subject { described_class.new(shopify_variant, spree_product) }

  context '#attributes' do
    let(:result) do
      {
        sku: shopify_variant.sku,
        price: shopify_variant.price,
        weight: shopify_variant.grams,
        position: shopify_variant.position,
        product_id: spree_product.id,
        track_inventory: shopify_variant.inventory_management.eql?('shopify')
      }
    end

    it 'creates a hash of variant attributes' do
      expect(subject.attributes).to eq result
    end
  end

  context '#option_value_ids' do
    let(:option_type) { create(:option_type) }
    let!(:f_option_value) do
      create(:option_value, name: shopify_variant.option1.strip.downcase, option_type: option_type)
    end
    let!(:s_option_value) do
      create(:option_value, name: shopify_variant.option2.strip.downcase, option_type: option_type)
    end
    let(:result) { [f_option_value.id, s_option_value.id, t_option_value.id] }

    context 'with valid product associations' do
      let!(:t_option_value) do
        create(:option_value, name: shopify_variant.option3.strip.downcase, option_type: option_type)
      end

      before { spree_product.option_types << option_type }

      it 'returns option value ids' do
        expect(subject.option_value_ids).to match_array(result)
      end
    end

    context "when product has't got option types" do
      let!(:t_option_value) do
        create(:option_value, name: shopify_variant.option3.strip.downcase, option_type: option_type)
      end

      it 'raises record not found' do
        expect do
          subject.option_value_ids
        end.to raise_error(ActiveRecord::RecordNotFound).with_message("Couldn't find Spree::OptionValue")
      end
    end

    context 'when one of option values does not exists' do
      before { spree_product.option_types << option_type }

      it 'raises record not found' do
        expect do
          subject.option_value_ids
        end.to raise_error(ActiveRecord::RecordNotFound).with_message("Couldn't find Spree::OptionValue")
      end
    end
  end

  context '#track_inventory?' do
    context 'shopify variant has inventory_management == shopify' do
      let(:shopify_variant) { create(:shopify_variant, inventory_management: 'shopify') }

      it 'returns true' do
        expect(subject).to be_track_inventory
      end
    end

    context 'shopify variant has inventory_management other than shopify' do
      let(:shopify_variant) { create(:shopify_variant, inventory_management: 'global') }

      it 'returns true' do
        expect(subject).not_to be_track_inventory
      end
    end
  end
end
