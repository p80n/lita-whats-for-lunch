require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require 'lita-whats-for-lunch/restaurants'

require "lita/handlers/whats_for_lunch"

Lita::Handlers::WhatsForLunch.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
