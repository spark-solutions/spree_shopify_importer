require 'spec_helper'

describe SpreeShopifyImporter::DataParsers::Promotions::BaseData, type: :service do
  subject { described_class.new(shopify_discount_code) }

  let(:shopify_discount_code) { build_stubbed(:shopify_discount_code) }

  describe '#attributes' do
    let(:result) do
      {
        name: shopify_discount_code.code.downcase,
        code: shopify_discount_code.code.downcase
      }
    end

    it 'return hash of promotion attributes' do
      expect(subject.attributes).to eq result
    end
  end

  describe '#expires_at' do
    it 'return current time' do
      expect(subject.expires_at).to be_within(1).of(Time.current)
    end
  end
end
