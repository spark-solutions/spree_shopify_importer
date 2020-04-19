require "spec_helper"

describe SpreeShopifyImporter::Importers::ProductImporter, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(resource) }

  before { authenticate_with_shopify }
  after { ShopifyAPI::Base.clear_session }

  describe "#import!", vcr: { cassette_name: "shopify/base_product" } do
    let(:resource) { ShopifyAPI::Product.find(11_101_525_828).to_json }

    it "creates shopify data feeds" do
      expect do
        perform_enqueued_jobs do
          subject.import!
        end
      end.to change(SpreeShopifyImporter::DataFeed, :count).by(4)
    end

    it "creates spree products" do
      expect do
        perform_enqueued_jobs do
          subject.import!
        end
      end.to change(Spree::Product, :count).by(1)
    end

    it "creates spree variants" do
      expect do
        perform_enqueued_jobs do
          subject.import!
        end
      end.to change(Spree::Variant, :count).by(2)
    end

    context "with existing" do
      context "data feed" do
        let(:data_feed) do
          create(:shopify_data_feed,
                 shopify_object_id: 11_101_525_828,
                 shopify_object_type: "ShopifyAPI::Product",
                 data_feed: resource.to_json,
                 spree_object: spree_object)
        end
        let(:spree_object) { nil }

        before do
          data_feed
        end

        it "creates shopify data feeds" do
          expect do
            perform_enqueued_jobs do
              subject.import!
            end
          end.to change(SpreeShopifyImporter::DataFeed, :count).by(3)
        end

        it "creates spree products" do
          expect do
            perform_enqueued_jobs do
              subject.import!
            end
          end.to change(Spree::Product, :count).by(1)
        end

        it "creates spree variants" do
          expect do
            perform_enqueued_jobs do
              subject.import!
            end
          end.to change(Spree::Variant, :count).by(2)
        end

        context "and product" do
          let(:spree_object) { create(:product) }

          it "creates only variant shopify data feeds" do
            expect do
              perform_enqueued_jobs do
                subject.import!
              end
            end.to change(SpreeShopifyImporter::DataFeed, :count).by(3)
          end

          it "does not create spree products" do
            expect do
              perform_enqueued_jobs do
                subject.import!
              end
            end.not_to change(Spree::Product, :count)
          end

          it "creates spree variants" do
            expect do
              perform_enqueued_jobs do
                subject.import!
              end
            end.to change(Spree::Variant, :count).by(1)
          end
        end
      end
    end
  end
end
