module Spree::ProductDecorator
  Spree::Product.include Spree::ActsAsTaggable
end

Spree::Product.prepend Spree::ProductDecorator
