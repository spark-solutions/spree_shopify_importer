require 'acts-as-taggable-on'

ActsAsTaggableOn::Tag.class_eval do
  self.table_name_prefix = 'spree_'
end

ActsAsTaggableOn::Tagging.class_eval do
  self.table_name_prefix = 'spree_'

  # temporary:
  # belongs_to :tagger, { polymorphic: true, optional: true }
  _validators.reject!{ |key, _| key == :tagger }

  ActsAsTaggableOn::Tagging._validate_callbacks = ActsAsTaggableOn::Tagging._validate_callbacks.reject do |callback|
    callback.raw_filter.attributes == [:tagger]
  end
end

# temporary:
Spree::Product.class_eval do
  acts_as_taggable
end
