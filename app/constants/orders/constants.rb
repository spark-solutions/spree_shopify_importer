# frozen_string_literal: true

module Orders
  module Constants
    module Payments
      module Spree
        BALANCE_DUE = "balance_due"
        FAILED = "failed"
        CREDIT_OWED = "credit_owed"
        PAID = "paid"
        VOID = "void"
      end

      module Shopify
        PENDING = "pending"
        AUTHORIZED = "authorized"
        PARTIALLY_PAID = "partially_paid"
        PAID = "paid"
        PARTIALLY_REFUNDED = "partially_refunded"
        REFUNDED = "refunded"
        VOIDED = "voided"
      end
    end

    module Shipments
      module Spree
        SHIPPED = "shipped"
        PARTIAL = "partial"
        READY = "ready"
        PENDING = "pending"
      end

      module Shopify
        FULFILLED = "fulfilled"
        PARTIAL = "partial"
      end
    end

    module OrderStates
      RETURNED = "returned"
      COMPLETE = "complete"
      CANCELED = "canceled"
      PENDING = "pending"
    end
  end
end
