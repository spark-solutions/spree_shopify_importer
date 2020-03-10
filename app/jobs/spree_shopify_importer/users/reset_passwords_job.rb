# frozen_string_literal: true

module SpreeShopifyImporter
  module Users
    class ResetPasswordsJob < ApplicationJob
      def perform(users)
        users.find_each(&:send_reset_password_instructions)
      end
    end
  end
end
