require 'json'
require 'rest-client'

module LitaWhatsForLunch
  module Restaurants


    def ban_restaurant(response)

    end


    def pick_restaurant(response)

      return unless valid?(response)

      response.reply("You are going to: #{restaurants(response).sample}")
    end


    # helper methods
    def restaurants(response)
      restaurants = Lita.redis.get('restaurants')
      p restaurants
      p restaurants.class
      unless restaurants
        api_root = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        response.reply("Hmmmm.... this is a tough one....")
        resp = RestClient.get("#{api_root}?location=#{location}&radius=500&type=restaurant&key=#{api_key}")

        # FIXME handle bad response
        json = JSON.parse(resp.body)

        while json['next_page_token']
          json['results'].each {|result|
            puts "Adding #{result['name']}"
            Lita.redis.lpush(result['name'])
            restaurants << result['name'] }
          puts "Requesting next page of results in 5 seconds..."
          sleep 5
          response.reply("Still pondering...")
          resp = RestClient.get("#{api_root}?pagetoken=#{json['next_page_token']}&key=#{api_key}")

          if resp.code == 200
            json = JSON.parse(resp.body)
          else
            json = {}
          end
        end
        restaurants
#        puts "Caching restaurant list"
#        Lita.redis.set('restaurants', restaurants.to_json)
#        Lita.redis.expire('restaurants', 24 * 3600 * 7)
      end
    end

    def valid?(response)
      unless api_key
        response.reply("Please provide me with the Google API key of your choosing")
        return
      end
      unless location
        response.reply("Please provide me with a location to center my search around")
        return
      end
    end

    def api_key
      @api_key ||= Lita.redis.get('api-key')
    end

    def location
      @location ||= Lita.redis.get('location-coordinates')
    end

  end
end
