require 'spec_helper'

RSpec.describe SpreeShopifyImporter::Importers::BaseImporter, type: :service do
  describe '#import!' do
    context 'shopify class' do
      let(:expected_message) { I18n.t('errors.not_implemented.shopify_class') }

      it 'raises not implemented error for shopify object' do
        expect { described_class.new.import! }.to raise_error(NotImplementedError).with_message(expected_message)
      end
    end

    context 'creator' do
      let(:expected_message) { I18n.t('errors.not_implemented.creator') }
      let(:data_feed_with_blank_spree_object) { double('DataFeed', spree_object: nil) }
      let(:data_feeds_creator) { instance_double(SpreeShopifyImporter::DataFeeds::Create) }

      before do
        expect(SpreeShopifyImporter::DataFeeds::Create).to receive(:new).and_return(data_feeds_creator)
        expect(data_feeds_creator).to receive(:save!).and_return(data_feed_with_blank_spree_object)
      end

      it 'raises not implemented error for creator' do
        allow_any_instance_of(described_class).to receive(:shopify_object).and_return(instance_spy('ShopifyObject'))

        expect { described_class.new.import! }.to raise_error(NotImplementedError).with_message(expected_message)
      end
    end

    context 'updater' do
      let(:expected_message) { I18n.t('errors.not_implemented.updater') }
      let(:spree_object) { instance_double('SpreeObject') }
      let(:data_feed_with_spree_object) { double('DataFeed', spree_object: spree_object) }
      let(:data_feeds_updater) { instance_double(SpreeShopifyImporter::DataFeeds::Update) }

      before do
        expect(SpreeShopifyImporter::DataFeeds::Update).to receive(:new).and_return(data_feeds_updater)
        expect(data_feeds_updater).to receive(:update!).and_return(data_feed_with_spree_object)
      end

      it 'raises not implemented error for updater' do
        allow_any_instance_of(described_class).to receive(:find_existing_data_feed).and_return(instance_double('DataFeed'))
        allow_any_instance_of(described_class).to receive(:shopify_object).and_return(instance_spy('ShopifyObject'))

        expect { described_class.new.import! }.to raise_error(NotImplementedError).with_message(expected_message)
      end
    end
  end
end
