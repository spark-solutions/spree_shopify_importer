require 'spec_helper'

describe SpreeShopifyImporter::DataSavers::Products::ProductCreator, type: :service do
  include ActiveJob::TestHelper

  subject { described_class.new(product_data_feed) }

  let(:delivery_profile_importer) { instance_double(SpreeShopifyImporter::Importers::DeliveryProfileImporter) }
  before  do
    authenticate_with_shopify
    expect(SpreeShopifyImporter::Importers::DeliveryProfileImporter).to receive(:new).and_return(delivery_profile_importer)
    expect(delivery_profile_importer).to receive(:call)
  end
  after   { ShopifyAPI::Base.clear_session }

  describe '#create!' do
    context 'with base product data feed', vcr: { cassette_name: 'shopify/base_product' } do
      let(:shopify_product) { ShopifyAPI::Product.find(11_101_525_828) }
      let(:product_data_feed) do
        create(:shopify_data_feed,
               shopify_object_id: shopify_product.id, data_feed: shopify_product.to_json)
      end

      it 'create spree product' do
        expect { subject.create! }.to change(Spree::Product, :count).by(1)
      end

      it 'assigns shopify data feed to product' do
        subject.create!
        expect(product_data_feed.reload.spree_object).to eq Spree::Product.find_by!(name: shopify_product.title)
      end

      context 'product attributes' do
        let(:spree_product) { Spree::Product.find_by!(slug: shopify_product.handle) }
        let(:shipping_category) { Spree::ShippingCategory.find_by!(name: I18n.t(:shopify)) }

        before { subject.create! }

        it 'description' do
          expect(spree_product.description).to eq shopify_product.body_html
        end

        it 'available_on' do
          expect(spree_product.available_on).to eq shopify_product.published_at
        end

        it 'slug' do
          expect(spree_product.slug).to eq shopify_product.handle
        end

        it 'created_at' do
          expect(spree_product.created_at).to eq shopify_product.created_at
        end

        it 'price' do
          expect(spree_product.price).to eq shopify_product.variants.first.price.to_d
        end

        it 'shipping_category' do
          expect(spree_product.shipping_category).to eq shipping_category
        end
      end

      context 'product tags' do
        let(:spree_product) { Spree::Product.find_by!(slug: shopify_product.handle) }

        xit 'creates product tags' do
          subject.create!
          # expect(spree_product.tag_list).to match_array %w[tag some product]
        end
      end

      context 'spree variants' do
        let(:spree_product) { Spree::Product.find_by!(slug: shopify_product.handle) }

        it 'enqueue a variant importer job' do
          expect { subject.create! }.to enqueue_job(SpreeShopifyImporter::Importers::VariantImporterJob).once
        end

        it 'creates spree variant' do
          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change(Spree::Variant, :count).by(2)
        end

        it 'assings variants to product' do
          perform_enqueued_jobs do
            subject.create!
          end

          expect(Spree::Variant.last.product).to eq spree_product
        end

        it 'creates data feeds' do
          variant_scope = { shopify_object_type: 'ShopifyAPI::Variant' }

          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change { SpreeShopifyImporter::DataFeed.where(variant_scope).reload.count }.by(1)
        end

        context 'with variant image', vcr: { cassette_name: 'shopify/product_with_variant_image' } do
          it 'creates spree image' do
            expect do
              perform_enqueued_jobs do
                subject.create!
              end
            end.to change { Spree::Image.count }.by(2)
          end
        end
      end

      context 'spree images' do
        let(:spree_product) { Spree::Product.find_by!(slug: shopify_product.handle) }

        it 'enqueue a variant importer job' do
          expect { subject.create! }.to enqueue_job(SpreeShopifyImporter::Importers::ImageImporterJob).once
        end

        it 'creates spree variant' do
          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change(Spree::Image, :count).by(2)
        end

        it 'assings variants to product' do
          perform_enqueued_jobs do
            subject.create!
          end

          expect(Spree::Image.last.viewable).to eq spree_product.master
        end

        it 'creates data feeds' do
          image_scope = { shopify_object_type: 'ShopifyAPI::Image' }

          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change { SpreeShopifyImporter::DataFeed.where(image_scope).reload.count }.by(2)
        end
      end

      context 'option types' do
        let(:spree_product) { Spree::Product.find_by!(slug: shopify_product.handle) }
        let(:shopify_product) do
          create(:shopify_product_multiple_variants, variants_count: 2, options_count: 2, handle: 'some-handle')
        end
        let(:option_types_names) { shopify_product.options.map(&:name).map(&:downcase) }

        it 'creates variants' do
          expect do
            perform_enqueued_jobs do
              subject.create!
            end
          end.to change(Spree::Variant, :count).by(3)
        end

        it 'creates option types' do
          expect { subject.create! }.to change(Spree::OptionType, :count).by(2)
        end

        it 'assigns option types to product' do
          subject.create!
          expect(spree_product.option_types.pluck(:name)).to match_array option_types_names
        end

        context 'with case insensitive option values' do
          let!(:option_type1) { create(:option_type, name: shopify_product.options.first.name) }

          it 'creates option types' do
            expect { subject.create! }.to change(Spree::OptionType, :count).by(1)
          end

          it 'assigns option types to product' do
            subject.create!

            expect(spree_product.option_types).to include option_type1
          end
        end

        context 'option values' do
          let(:option_type1) { Spree::OptionType.find_by(name: shopify_product.options.first.name.downcase) }
          let(:option_type2) { Spree::OptionType.find_by(name: shopify_product.options.last.name.downcase) }
          let(:option_type1_values) { shopify_product.options.first.values.map(&:downcase) }
          let(:option_type2_values) { shopify_product.options.last.values.map(&:downcase) }

          it 'creates option values' do
            expect { subject.create! }.to change(Spree::OptionValue, :count).by(6)
          end

          it 'assigns option values to option types' do
            subject.create!
            expect(option_type1.option_values.pluck(:name)).to match_array option_type1_values
            expect(option_type2.option_values.pluck(:name)).to match_array option_type2_values
          end

          context 'with case insensitive' do
            let!(:option_type2) { create(:option_type, name: shopify_product.options.last.name) }
            let!(:option_type2_values) do
              shopify_product.options.last.values.map do |value|
                create(:option_value, option_type: option_type2, name: value)
              end
            end

            it 'creates option values' do
              expect { subject.create! }.to change(Spree::OptionValue, :count).by(3)
            end
          end
        end
      end
    end
  end
end
