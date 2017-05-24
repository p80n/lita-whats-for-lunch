require 'json'
require 'rest-client'

module LitaWhatsForLunch
  module Restaurants


    def ban_restaurant(response)
      Lita.redis.sadd('banned', response.matches[0][0])
    end

    def list_restaurants(response)
      response.reply("```#{restaurants(response).sort.join("\n")}```")
    end

    def pick_restaurant(response)
      return unless valid?(response)
      response.reply("you are going to: #{random_restaurant(response)}")
    end

    # helper methods
    def random_restaurant(response)
      (restaurants(response) - banned_restaurants).sample
    end

    def banned_restaurants
      lita.redis.smembers('banned') || []
    end

    def restaurants(response)
      restaurants = Lita.redis.smembers('restaurants')
      if restaurants.nil? or restaurants.empty?
        restaurants = []
        api_root = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        response.reply("Hmmmm.... this is a tough one....")
        resp = RestClient.get("#{api_root}?location=#{location}&radius=500&type=restaurant&key=#{api_key}")

        # FIXME handle bad response
        json = JSON.parse(resp.body)

        while json['next_page_token']
          json['results'].each {|result|
            puts "Adding #{result['name']}"
            restaurants << result['name'] }
          puts "Requesting next page of results in 5 seconds..."
          sleep 5
          resp = RestClient.get("#{api_root}?pagetoken=#{json['next_page_token']}&key=#{api_key}")

          if resp.code == 200
            response.reply("Still pondering...")
            json = JSON.parse(resp.body)
          else
            json = {}
          end
        end
        Lita.redis.sadd('restaurant', restaurants)
      end
      restaurants
    end

    def valid?(response)
      unless api_key
        response.reply("Please provide me with the Google API key of your choosing")
        return false
      end
      unless location
        response.reply("Please provide me with a location to center my search around")
        return false
      end
      return true
    end

    def api_key
      @api_key ||= Lita.redis.get('api-key')
    end

    def location
      @location ||= Lita.redis.get('location-coordinates')
    end

  end
end
