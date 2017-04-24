require 'spec_helper'

RSpec.describe Shopify::Import::Base, type: :model do
  subject { described_class }

  describe '.new' do
    context 'with credentials' do
      let(:credentials) { { api_key: 'foo', password: 'bar', shop_name: 'baz' } }

      it 'calls singleton for client with params' do
        expect_any_instance_of(Shopify::Import::Client).to receive(:get_connection).with(credentials)
        subject.new({ credentials: credentials })
      end
    end

    context 'without credentials' do
      it 'calls singleton for client with default values' do
        expect_any_instance_of(Shopify::Import::Client).to receive(:get_connection).with({})
        subject.new
      end
    end
  end

  describe '#count', :vcr do
    it 'raises error ActiveResource::ResourceNotFound' do
      expect { subject.new.count }.to raise_error ActiveResource::ResourceNotFound
    end
  end

  describe '#find', :vcr do
    it 'raises error ActiveResource::ResourceNotFound' do
      expect { subject.new.find(1) }.to raise_error ActiveResource::ResourceNotFound
    end
  end

  describe '#find_and_import', :vcr do
    it 'raises error ActiveResource::ResourceNotFound' do
      expect { subject.new.find_and_import(1) }.to raise_error ActiveResource::ResourceNotFound
    end
  end
end
