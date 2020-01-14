# frozen_string_literal: true

module SpreeShopifyImporter
  module DataSavers
    module Zones
      class ZoneBase < BaseDataSaver
        delegate :attributes, to: :parser
        COUNTRY = 'country'
        STATE = 'state'

        def parser
          @parser ||= SpreeShopifyImporter::DataParsers::Zones::BaseData.new(
            @shopify_object, @parent_object, @spree_zone_kind
          )
        end

        def create_spree_zone_member
          spree_zone_kind == COUNTRY ? create_country_member : create_state_member
          Spree::ZoneMember.create!(
            zoneable_type: @spree_member.class.name,
            zoneable_id: @spree_member.id,
            zone_id: @spree_zone.id
          )
        end

        def spree_zone_kind
          @spree_zone_kind = @shopify_object.is_a?(ShopifyAPI::Country) ? COUNTRY : STATE
        end

        def create_country_member
          @spree_member = Spree::Country.find_by(iso: @shopify_object.code)
        end

        def create_state_member
          abbr = @shopify_object.code
          name = @shopify_object.name
          spree_country_id = Spree::Country.find_by!(iso: @country.code).id

          if (@spree_member = spree_state(abbr, name, spree_country_id))
            @spree_member.update!(abbr: abbr, name: name)
          else
            @spree_member = Spree::State.create!(abbr: abbr, country_id: spree_country_id, name: name)
          end
        end

        def spree_state(abbr, name, spree_country_id)
          Spree::State.find_by(abbr: abbr, country_id: spree_country_id) || Spree::State.find_by(name: name, country_id: spree_country_id)
        end

        def profile_name
          @profile_name = attributes['profile_name']
        end

        def update_rest_of_world_zone
          rest_of_world_country_zone = Spree::Zone.find_by(name: "Rest of World - Countries/#{profile_name}")
          RestOfWorldZones::UpdateJob.perform_later(@spree_member, rest_of_world_country_zone, @profile_name) if rest_of_world_country_zone.present?
        end

        def create_or_update_tax_rate
          SpreeShopifyImporter::DataSavers::TaxRates::TaxRateCreator.new(@spree_zone, @shopify_object).create!
        end
      end
    end
  end
end
