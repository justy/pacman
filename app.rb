# server.rb
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'sinatra/reloader' if development?


get '/injest/:source' do |source|

  #puts "Source: " + source
  server = "http://" + source
  stuff = Hpricot(open(server))
  puts stuff
  injest stuff
  

end

def injest source_json
  
   # Construct a new feed
    newFeed = {}

    # Read in the list of mappings into an easy to access hash
    hashtributes = {}
    counter = 1
    begin
      file = File.open("mappings.rb", "r")
      while (line = file.gets)

        counter = counter + 1

        if false #mappingString.chr == "#"
          # Ignore comments
        else
          # It's a mapping, so grab the source key and destination key
          keyVals = line.split(',')
          key = keyVals[0]
          val = keyVals[1].gsub("\n","")
          #puts "Key: #{key} Value:#{val}"
          hashtributes[key] = val
        end
      end
      file.close
    rescue => err
      puts "Exception: #{err}"
      err
    end


    # for each fire'
    require 'json' #=> true
    feedJSON = JSON.parse(source_json)

    # puts feedJSON

    head = feedJSON['head']
    newFeed['head'] = head

    body = feedJSON['body']
    fires = body['fires']
    newFires = Array.new


    fires.each do |fire|
      #puts "Fire: #{fire}\n"

      newFire = {'attributes' => {}}

      # for each attribute in our mapper

      hashtributes.each_pair do |k,v|

        #puts "Key: #{k} Value:#{v}"

        # Grab the value of the key key
        fireVal = fire[k]

        # Insert it into the value of the val key
        newFire['attributes'][v.gsub("attributes.","")] = fireVal   
  
        if v.split('.').length > 1
          # nested attribute 
        else
          # normal attribute
          newFire[v] = fireVal

        end

      

      end

      #puts newFire
      newFires << newFire


    end

    newBody = {'fires' => newFires}
    newFeed['body'] = newBody
    puts newFeed.to_json

    newFeed.to_json

  end

# return an injested version of dummy_feed.json
# Kept for legacy

get '/' do

  # Construct a new feed
  newFeed = {}

  # Read in the list of mappings into an easy to access hash
  hashtributes = {}
  counter = 1
  begin
    file = File.open("mappings.rb", "r")
    while (line = file.gets)

      counter = counter + 1

      if false #mappingString.chr == "#"
        # Ignore comments
      else
        # It's a mapping, so grab the source key and destination key
        keyVals = line.split(',')
        key = keyVals[0]
        val = keyVals[1].gsub("\n","")
        #puts "Key: #{key} Value:#{val}"
        hashtributes[key] = val
      end
    end
    file.close
  rescue => err
    puts "Exception: #{err}"
    err
  end


  # for each fire'
  require 'json' #=> true
  feedFile = String.new(File.open("dummy_feed.json", 'r').read)
  #puts feedFile

  feedJSON = JSON.parse(feedFile)

  # puts feedJSON

  head = feedJSON['head']
  newFeed['head'] = head

  body = feedJSON['body']
  fires = body['fires']
  newFires = Array.new


  fires.each do |fire|
    #puts "Fire: #{fire}\n"

    newFire = {'attributes' => {}}

    # for each attribute in our mapper

    hashtributes.each_pair do |k,v|

      #puts "Key: #{k} Value:#{v}"

      # Grab the value of the key key
      fireVal = fire[k]

      # Insert it into the value of the val key

      if v.split('.').length > 1
        # nested attribute 
          newFire['attributes'][v.gsub("attributes.","")] = fireVal   
      else
        # normal attribute
        newFire[v] = fireVal

      end

    

    end

    #puts newFire
    newFires << newFire


  end

  newBody = {'fires' => newFires}
  newFeed['body'] = newBody
  puts newFeed.to_json

  newFeed.to_json

end