require 'json'
require 'rest-client'

module LitaWhatsForLunch
  module Restaurants


    def ban_restaurant(response)
      Lita.redis.sadd('banned', response.matches[0][0])
      response.reply("#{response.matches[0][0]} is dead to us :coffin:")
    end

    def list_restaurants(response)
      keyword = response.matches[0][0]
      response.reply("```#{restaurants(response).sort.join("\n")}```")
    end

    def pick_restaurant(response)
      return unless valid?(response)
      response.reply("You are going to: #{random_restaurant(response)}")
    end

    def pick_breakfast_spot(response)
      response.reply "#{random_restaurant(response,'breakfast')} sounds good"
    end

    def feeling_choosy(response)
      keyword = response.matches[0][0]
      response.reply "What about #{random_restaurant(response,keyword)}?"
    end

    def add_restaurant(response)
      restaurant = response.matches[0][0]
      if Lita.redis.smembers('restaurants').include?(restaurant)
        response.reply "Already knew about #{restaurant}"
      else
        Lita.redis.sadd('restaurants', restaurant)
        response.reply "Done! #{restaurant} has been added to the list"
      end
    end

    # helper methods
    def random_restaurant(response,keyword="")
      (restaurants(response,keyword) - banned_restaurants).sample
    end

    def banned_restaurants
      Lita.redis.smembers('banned') || []
    end

    def restaurants(response, keyword="")
      restaurants = Lita.redis.smembers("restaurants:#{keyword}")
      if restaurants.nil? or restaurants.empty?
        response.reply("Hmmmm.... this is a tough one....")
        restaurants = []
        api_root = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        query = "#{api_root}?location=#{location}&radius=800&type=restaurant&key=#{api_key}"
        query += "&keyword=#{keyword}" unless keyword.empty?
        puts query
        resp = RestClient.get(query)

        # FIXME handle bad response
        json = JSON.parse(resp.body)

        while json['next_page_token']
          json['results'].each {|result|
            puts "Adding #{result['name']}"
            restaurants << result['name'] }
          break unless keyword.empty? # only the ~ first page of results seems pertinent for keyword searches
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
        Lita.redis.sadd("restaurants:#{keyword}", restaurants)
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
      @api_key ||= ENV['API_KEY'] || Lita.redis.get('api-key')
    end

    def location
      @location ||= ENV['LOCATION_COORDINATES'] || Lita.redis.get('location-coordinates')
    end

  end
end
