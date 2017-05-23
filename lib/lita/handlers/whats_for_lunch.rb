module Lita
  module Handlers
    class WhatsForLunch < Handler
      include ::LitaWhatsForLunch::Restaurants

      name = 'lita'
      Lita.configure{|config| name = config.robot.name}

      route(/whats for lunch\??/, :pick, help: { "#{name}: whats for lunch?" => '#{name} will help you answer the age old question' })
      route(/lunch?/, :pick, help: { "#{name}: lunch?" => '#{name} will help you answer the age old question' })

      Lita.register_handler(self)
    end
  end
end
