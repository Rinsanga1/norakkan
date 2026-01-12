Rails.application.config.active_storage.variant_processor = :mini_magick

# Define image variants
Rails.application.config.active_storage.variants = {
  thumb: { resize_to_limit: [ 200, 200 ] },
  medium: { resize_to_limit: [ 500, 500 ] },
  large: { resize_to_limit: [ 1200, 1200 ] }
}
