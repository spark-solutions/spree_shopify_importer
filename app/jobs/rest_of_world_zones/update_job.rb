# frozen_string_literal: true

module RestOfWorldZones
  class UpdateJob < ApplicationJob
    SPREE_STATE = 'Spree::State'

    def perform(spree_member, rest_of_world_country_zone, profile_name)
      @spree_member = spree_member
      @rest_of_world_country_zone = rest_of_world_country_zone
      @profile_name = profile_name
      update_rest_of_world_zones
    end

    def update_rest_of_world_zones
      @spree_member.is_a?(Spree::Country) ? update_rest_of_world_country_zone : update_rest_of_world_state_zone
    end

    def update_rest_of_world_country_zone
      Spree::ZoneMember.find_by(zoneable_id: @spree_member.id, zone_id: @rest_of_world_country_zone.id)&.destroy!
    end

    def rest_of_world_state_zone
      @rest_of_world_state_zone = Spree::Zone.find_or_create_by!(
        name: "Rest of World - States/#{@profile_name}",
        description: 'shopify shipping to States Rest of World',
        kind: 'state'
      )
    end

    def update_rest_of_world_state_zone
      if existed_spree_zone_country_member_for_state
        create_states_members
        @existed_spree_zone_country_member_for_state.destroy!
      else
        Spree::ZoneMember.find_by(
          zoneable_type: SPREE_STATE,
          zoneable_id: @spree_member.id,
          zone_id: rest_of_world_state_zone.id
        )&.destroy!
      end
    end

    def create_states_members
      Spree::State
        .where(country_id: @spree_member.country_id)
        .where.not(id: @spree_member.id).each do |state|
          Spree::ZoneMember.create!(
            zoneable_type: SPREE_STATE,
            zoneable_id: state.id,
            zone_id: rest_of_world_state_zone.id
          )
        end
    end

    def existed_spree_zone_country_member_for_state
      @existed_spree_zone_country_member_for_state = Spree::ZoneMember.find_by(
        zoneable_id: @spree_member.country_id,
        zone_id: @rest_of_world_country_zone.id
      )
    end
  end
end
