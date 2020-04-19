require "spec_helper"

describe SpreeShopifyImporter::DataSavers::Users::UserUpdater, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(customer_data_feed, spree_user) }

  let(:customer_data_feed) { create(:shopify_data_feed, data_feed: shopify_customer.to_json) }
  let(:shopify_customer) do
    ShopifyAPI::Customer.new(
      created_at: 2.days.ago, email: "user@example.com",
      first_name: "User", last_name: "Example"
    )
  end
  let(:spree_user) { create(:user) }

  describe "#create!" do
    context "with base customer data feed" do
      it "generates correct attributes and associations" do
        subject.update!

        expect(spree_user.spree_api_key).not_to be_blank
        expect(spree_user.email).to eq(shopify_customer.email)
        expect(spree_user.login).to eq(shopify_customer.email)
      end

      context "customer associations" do
        let(:shopify_address) { build_stubbed(:shopify_address) }

        before do
          expect_any_instance_of(ShopifyAPI::Customer).to receive(:addresses).and_return([shopify_address])
        end

        it "creates spree address" do
          expect do
            perform_enqueued_jobs do
              subject.update!
            end
          end.to change(Spree::Address, :count).by(2)
        end
      end
    end
  end
end
