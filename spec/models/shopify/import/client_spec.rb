require 'spec_helper'

RSpec.describe Shopify::Import::Client, type: :model do
  describe '.instance' do
    context 'with valid credentials' do
      let(:credentials) { { api_key: 'foo',
                            password: 'baz',
                            shop_name: 'test_shop' } }
      let(:client) { described_class.instance }
      let(:site) { 'https://foo:baz@test_shop.myshopify.com/admin' }

      before { client.get_connection(credentials) }

      it 'creates connection to shopify api' do
        expect(client.site).to eq site
      end
    end

    context 'without credentials' do
      let(:client) { described_class.instance }
      let(:site) { 'https://api_key:password@shop_name.myshopify.com/admin' }

      before { client.get_connection }

      it 'creates connection to shopify api using preferences' do
        expect(client.site).to eq site
      end
    end

    context 'with invalid credentials'
  end
end
