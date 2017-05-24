module Lita
  module Handlers
    class WhatsForLunch < Handler
      include ::LitaWhatsForLunch::Restaurants

      name = 'lita'
      Lita.configure{|config| name = config.robot.name}

      route(/whats for lunch\??/, :pick_restaurant, help: { "#{name}: whats for lunch?" => '#{name} will help you answer the age old question' })
      route(/lunch\?$/, :pick_restaurant, help: { "#{name}: lunch?" => '#{name} will help you answer the age old question' })
      route(/lunch ban (.+)/, :ban_restaurant, help: { "#{name}: ban restaurant" => '#{name} will not suggest this place anymore' })
      route(/lunch options/, :list_restaurants, help: { "#{name}: ban restaurant" => '#{name} will not suggest the indicated dump anymore' })

      route(/whats for breakfast\??/, :pick_breakfast_spot)

      route(/i'm (?:feeling|jonesing|jonesing for) (\w+)/, :feeling_choosy)

      route(/lunch location ([^\s]+)/, :set_location, help: { "#{name}: lunch location LAT,LONG" => 'Set the coordinates for searches to occur arround' })
      route(/lunch api-key (\w+)/, :set_api_key, help: { "#{name}: lunch api-key KEY" => 'Set the Google Maps API key to use' })


      Lita.register_handler(self)




      def set_api_key(response)
        puts "Updating redis with api-key #{response.matches[0][0]}"
        Lita.redis.set('api-key', response.matches[0][0])
      end
      def set_location(response)
        puts "Updating redis with location-coordinates #{response.matches[0][0]}"
        Lita.redis.set('location-coordinates', response.matches[0][0])
      end

    end
  end
end
