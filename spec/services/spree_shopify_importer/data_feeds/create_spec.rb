require "spec_helper"

RSpec.describe SpreeShopifyImporter::DataFeeds::Create, type: :service do
  subject { described_class.new(shopify_object, parent) }

  let(:shopify_object) { build_stubbed(:shopify_product) }
  let(:parent) { nil }

  describe "save!" do
    context "shopify product" do
      it "creates shopify data feed" do
        expect { subject.save! }.to change(SpreeShopifyImporter::DataFeed, :count).by(1)
      end

      context "saves" do
        it "returns correct attributes" do
          data_feed = subject.save!

          expect(data_feed.shopify_object_id).to eq shopify_object.id
          expect(data_feed.shopify_object_type).to eq "ShopifyAPI::Product"
          expect(data_feed.data_feed).to eq shopify_object.to_json.to_s
          expect(data_feed.parent).to be_nil
        end

        context "with existing parent" do
          let(:parent) { build_stubbed(:shopify_data_feed) }

          it "assigns parent to data feed" do
            data_feed = subject.save!

            expect(data_feed.parent).to eq parent
          end
        end
      end
    end
  end
end
