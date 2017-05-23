module Lita
  module Handlers
    class WhatsForLunch < Handler

      name = 'lita'
      Lita.configure{|config| name = config.robot.name}

      route(/whats for lunch\??/, :pick_restaurant, help: { "#{name}: whats for lunch?" => '#{name} will help you answer the age old question' })
      route(/lunch?/, :pick_restaurant, help: { "#{name}: lunch?" => '#{name} will help you answer the age old question' })

      Lita.register_handler(self)
    end
  end
end
