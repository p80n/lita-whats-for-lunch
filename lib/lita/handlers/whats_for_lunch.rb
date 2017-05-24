module Lita
  module Handlers
    class WhatsForLunch < Handler
      include ::LitaWhatsForLunch::Restaurants

      name = 'lita'
      Lita.configure{|config| name = config.robot.name}

      route(/whats for lunch\??/, :pick_restaurant, help: { "#{name}: whats for lunch?" => "#{name} will help you answer the age old question" })
      route(/lunch\?$/, :pick_restaurant, help: { "#{name}: lunch?" => 'see above' })
      route(/lunch ban (.+)/, :ban_restaurant, help: { "#{name}: ban restaurant" => "#{name} will not suggest this place anymore" })
      route(/lunch options\s*(\w+)/, :list_restaurants, help: { "#{name}: lunch options [CUSINE]" => 'List restaurants, optionally limited to a keyword' })

      route(/what.?s for breakfast\??/, :pick_breakfast_spot, help: { "#{name}: what's for breakfast?" => 'Pick a spot for breakfast' } )

      route(/i(?:.m)* (?:feeling|hungry|jonesing|want)(?: for)* (\w+)/i, :feeling_choosy, help: { "#{name}: i want CUISINE" => "#{name} will search for a spot serving CUSISINE" } )

      route(/lunch location ([^\s]+)/, :set_location, help: { "#{name}: lunch location LAT,LONG" => 'Set the coordinates for searches to occur arround' })
      route(/lunch api-key (\w+)/, :set_api_key, help: { "#{name}: lunch api-key KEY" => 'Set the Google Maps API key to use' })
      route(/lunch add (.+)/, :add_restaurant, help: { "#{name}: lunch add RESTAURANT" => "Add a restaurant #{name} doesn't know about" })

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
