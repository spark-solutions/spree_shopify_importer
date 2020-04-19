# frozen_string_literal: true

module RestOfWorldZones
  class CreateJob < ApplicationJob
    SPREE_STATE = "Spree::State"
    SPREE_COUNTRY = "Spree::Country"

    def perform(shopify_shipping_zone, shipping_methods)
      @shopify_shipping_zone = ShopifyAPI::ShippingZone.new(JSON.parse(shopify_shipping_zone))
      @existed_spree_zones_by_member_type = existed_spree_zones_by_member_type
      @profile_name = profile_name
      @shipping_methods = shipping_methods
      create_rest_of_world_country_zone
      assign_zone_to_shipping_metohods
    end

    private

    def existed_spree_zones_by_member_type
      Spree::Zone.where("name like ?", "%#{@profile_id}%").map(&:members).flatten.group_by(&:zoneable_type)
    end

    def profile_id
      @shopify_shipping_zone.profile_id.split("/").last
    end

    def profile_name
      Spree::TaxCategory.find_by("name like ?", "%#{profile_id}").name.split("/").first
    end

    def create_rest_of_world_country_zone
      @rest_of_world_country_zone = find_or_create_spree_zone(
        "Rest of World - Countries/#{@profile_name}",
        "Shopify shipping to Countries Rest of World",
        "country"
      )
      create_rest_of_world_state_zone if @existed_spree_zones_by_member_type.key?(SPREE_STATE)
      create_country_members
      create_or_update_tax_rate(@rest_of_world_country_zone)
    end

    def create_rest_of_world_state_zone
      @rest_of_world_state_zone = find_or_create_spree_zone(
        "Rest of World - States/#{@profile_name}",
        "Shopify shipping to States Rest of World",
        "state"
      )
      create_states_members
      create_or_update_tax_rate(@rest_of_world_state_zone)
    end

    def create_states_members
      Spree::State
        .where(country_id: find_excluded_countries_ids_of_excluded_states)
        .where.not(id: @excluded_states_ids).each do |state|
          find_or_create_spree_zone_member(SPREE_STATE, state.id, @rest_of_world_state_zone.id)
        end
    end

    def create_country_members
      Spree::Country.where.not(id: find_excluded_countries_ids).each do |country|
        find_or_create_spree_zone_member(SPREE_COUNTRY, country.id, @rest_of_world_country_zone.id)
      end
    end

    def find_or_create_spree_zone(name, description, kind)
      Spree::Zone.find_or_create_by!(
        name: name,
        description: description,
        kind: kind
      )
    end

    def find_or_create_spree_zone_member(zoneable_type, zoneable_id, zone_id)
      Spree::ZoneMember.find_or_create_by!(
        zoneable_type: zoneable_type,
        zoneable_id: zoneable_id,
        zone_id: zone_id
      )
    end

    def find_excluded_states_ids
      @excluded_states_ids = @existed_spree_zones_by_member_type[SPREE_STATE]&.pluck(:zoneable_id)
    end

    def find_excluded_countries_ids_of_excluded_states
      @excluded_countries_ids_of_excluded_states = Spree::State.where(id: find_excluded_states_ids).pluck(:country_id)
    end

    def find_excluded_whole_countries_ids
      @existed_spree_zones_by_member_type[SPREE_COUNTRY]&.pluck(:zoneable_id)
    end

    def find_excluded_countries_ids
      find_excluded_whole_countries_ids.to_a + @excluded_countries_ids_of_excluded_states.to_a
    end

    def create_or_update_tax_rate(spree_zone)
      SpreeShopifyImporter::DataSavers::TaxRates::TaxRateCreator.new(spree_zone, @shopify_shipping_zone).create!
    end

    def assign_zone_to_shipping_metohods
      @shipping_methods.each do |shipping_method|
        shipping_method.zones << [@rest_of_world_country_zone, @rest_of_world_state_zone].compact
      end
    end
  end
end
