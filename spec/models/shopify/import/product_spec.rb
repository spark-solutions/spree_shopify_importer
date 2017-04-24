require 'spec_helper'

RSpec.describe Shopify::Import::Product, type: :module do
  subject { described_class.new }

  it 'is inheriting from base' do
    expect(described_class.superclass).to eq Shopify::Import::Base
  end

  describe '#find', vcr: { cassette_name: 'shopify/product/find' } do
    it 'returns ShopifyAPI::Product object' do
      expect(subject.find(9884552707)).to be_kind_of ShopifyAPI::Product
    end

    it 'returns a proper product' do
      expect(subject.find(9884552707).handle).to eq 'sample_product'
    end
  end

  describe '#count', vcr: { cassette_name: 'shopify/product/count' } do
    let(:result) { { 'count' => 2 } }

    it 'returns number of products in shopify base' do
      expect(subject.count).to eq result
    end
  end

  describe '#find_all', vcr: { cassette_name: 'shopify/product/find_all' }  do
    it 'find all products in shopify' do
      expect(subject.find_all.length).to eq 2
    end
  end

  describe '#find_and_import', vcr: { cassette_name: 'shopify/product/find_and_import' } do
    it 'creates single data feed' do
      expect { subject.find_and_import(9884552707) }.to change(Shopify::DataFeed, :count).by(1)
    end

    it 'creates single spree product' do
      expect { subject.find_and_import(9884552707) }.to change(Spree::Product, :count).by(1)
    end
  end

  describe '#find_all_first_and_import', vcr: { cassette_name: 'shopify/product/find_all_first_and_import' } do
    it 'creates data feeds' do
      expect { subject.find_all_first_and_import }.to change(Shopify::DataFeed, :count).by(2)
    end

    it 'creates single spree product' do
      expect { subject.find_all_first_and_import }.to change(Spree::Product, :count).by(2)
    end
  end
end
