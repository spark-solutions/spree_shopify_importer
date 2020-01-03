require 'spec_helper'

RSpec.describe SpreeShopifyImporter::Connections::Client, type: :model do
  describe '#get_connection' do
    let(:client) { described_class.instance }

    after { ShopifyAPI::Base.clear_session }

    context 'with api_key and password' do
      let(:credentials) do
        {
          api_key: '0a9445b7b067719a0af024610364ee34', password: '800f97d6ea1a768048851cdd99a9101a',
          shop_domain: 'spree-shopify-importer-test-store.myshopify.com', api_version: '2019-10'
        }
      end

      context 'valid credentials', vcr: { cassette_name: 'client/valid_credentials' } do
        it 'creates connection to Shopify API' do
          client.get_connection(credentials)
          expect(ShopifyAPI::Shop.current.attributes['domain']).to eq('spree-shopify-importer-test-store.myshopify.com')
        end
      end

      context 'invalid credentials' do
        context 'invalid api_key', vcr: { cassette_name: 'client/invalid_api_key' } do
          let(:invalid_api_key_credentials) { credentials.merge(api_key: 'invalid_key') }

          it 'raises ForbiddenAccess error' do
            expect do
              client.get_connection(invalid_api_key_credentials)
              ShopifyAPI::Shop.current
            end.to raise_error(ActiveResource::ForbiddenAccess)
          end
        end

        context 'invalid password', vcr: { cassette_name: 'client/invalid_password' } do
          let(:invalid_password_credentials) { credentials.merge(password: 'invalid_password') }

          it 'raises UnauthorizedAccess error' do
            expect do
              client.get_connection(invalid_password_credentials)
              ShopifyAPI::Shop.current
            end.to raise_error(ActiveResource::UnauthorizedAccess)
          end
        end

        context 'invalid shop_domain', vcr: { cassette_name: 'client/invalid_shop_domain' } do
        let(:invalid_shop_domain_credentials) { credentials.merge(shop_domain: 'example.myshopify.com') }

        it 'raises UnauthorizedAccess error' do
           expect do
             client.get_connection(invalid_shop_domain_credentials)
             ShopifyAPI::Shop.current
           end.to raise_error(ActiveResource::UnauthorizedAccess)
        end
        end
      end
    end

    context 'with auth token' do
      let(:credentials) do
        {
          shop_domain: 'spree-shopify-importer-test-store.myshopify.com',
          token: '918b6723f062d8805b364dba757782c5',
          api_version: '2019-10'
        }
      end

      context 'valid credentials', vcr: { cassette_name: 'client/valid_auth_token' } do
        # TODO: we need to record vcr with valid token
        xit 'initiates new session as installed app' do
          expect(client.get_connection(credentials)).to be_persisted
        end
      end

      context 'invalid auth token', vcr: { cassette_name: 'client/invalid_auth_token' } do
        let(:invalid_auth_token_credentials) { credentials.merge(token: 'invalid_token') }

        it 'raises UnauthorizedAccess error' do
          client.get_connection(invalid_auth_token_credentials)
          expect { ShopifyAPI::Shop.current }
            .to raise_error(ActiveResource::UnauthorizedAccess)
        end
      end

      context 'invalid shop_domain', vcr: { cassette_name: 'client/valid_auth_token_invalid_shop_domain' } do
        let(:invalid_shop_domain_credentials) { credentials.merge(shop_domain: 'example.myshopify.com') }

        it 'raises UnauthorizedAccess error' do
          client.get_connection(invalid_shop_domain_credentials)
          expect { ShopifyAPI::Shop.current }
            .to raise_error(ActiveResource::UnauthorizedAccess)
        end
      end
    end

    context 'without credentials' do
      it 'raises SpreeShopifyImporterer::ClientError error' do
        credentials = { shop_domain: 'spree-shopify-importer-test-store.myshopify.com' }

        expect { client.get_connection(credentials) }
          .to raise_error(SpreeShopifyImporter::Connections::ClientError,
                          I18n.t('shopify_import.client.missing_credentials'))
      end
    end
  end
end
