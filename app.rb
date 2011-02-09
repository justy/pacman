# Pacman - generic content driven injestor

# Provide it with a url to source from, and the name of a mappings file (json) and it returns an injested json feed



require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'sinatra/reloader' if development?

get '/' do

  source_feed = params[:source_feed]
  mappings_name = params[:mappings_name]
  desired_array_key = params[:key]
  preserve_meta = false
  
  preserve_meta = true if params[:meta].nil?
  
  if source_feed.nil? || mappings_name.nil? || desired_array_key.nil?
    return erb :usage
  end


  dputs "Source Feed: " + source_feed if !source_feed.nil?
  dputs "Mappings Name: " + mappings_name if !mappings_name.nil?
  dputs "Desired Array Key: " + desired_array_key if !desired_array_key.nil?

  source_url = "http://" + source_feed
  mappings_url = "mappings/" + mappings_name + ".json"

  #dputs "Source URL: " + source_url + " Mappings URL: " + mappings_url if !source_url.nil? && !mappings_url.nil?

  source_json = open(source_url).read
  #dputs "Source JSON: " + source_json
  mappings_json = File.open(mappings_url, 'r').read
  #dputs "Mappings JSON: " + mappings_json

  # Injest the provided feed using the provided mappings
  injest (source_json, mappings_json, desired_array_key, preserve_meta)


end



# Utilties

# Injest the feed provided as json in 'source', using the mappings provided as json in 'mappings'
def injest source_json, mappings_json, desired_array_key, preserve_meta

  #dputs source_json

  require 'json'

  # Construct a new feed
  newFeed = {}

  # Read in the list of mappings into an easy to access hash
  hashtributes = JSON.parse(mappings_json)

  # for each event'
  require 'json' #=> true
  feedJSON = JSON.parse(source_json)

  # puts feedJSON

  head = feedJSON['head']
  newFeed['head'] = head if preserve_meta

  body = feedJSON['body']
  desired_array = body[desired_array_key]
  newEvents = Array.new

  desired_array.each do |event|
    #puts "event: #{event}\n"

    newEvent = {'attributes' => {}}

    # for each attribute in our mapper

    hashtributes.each_pair do |k,v|

      #dputs "Key: #{k} Value:#{v}"
      #dputs "Class: #{v.class}"
      # Grab the value of the key key
      eventVal = event[k]

      # Do any special parsing required
      if v.class == Hash
        # In this case there's a spec for how the value will be mapped to the new value(s)

        delim = v['delimiter']
        destinationKeys = v['destination_keys']
        destinationValues = event[k].split(delim)
        #dputs "Delim: " + delim
        #dputs "Destination Keys: " + destination_keys.to_s
        arrayIndex = 0
        destinationKeys.each do |destinationKey|
          #dputs destinationKey
          # TODO: Allow this to use our 'attributes.foo' mechanism, as is done below
          if destinationKey.split('.').length > 1
             # nested attribute 
            newEvent['attributes'][destinationKey.gsub("attributes.","")] = destinationValues[arrayIndex]
          else
            newEvent[destinationKey] = destinationValues[arrayIndex] 
          end
          arrayIndex = arrayIndex + 1
        end

      else
        # puts no keys
        if v.split('.').length > 1
          # nested attribute 
          newEvent['attributes'][v.gsub("attributes.","")] = eventVal   
        else
          # normal attribute
          newEvent[v] = eventVal

        end
      end

    end

    #puts newevent
    newEvents << newEvent


  end

  newBody = {desired_array_key => newEvents}
 
  if preserve_meta
    newFeed['body'] = newBody
  else
    newFeed = newBody
  end
  
  #dputs newFeed.to_json

  newFeed.to_json



end



def dputs foo
  puts foo
end
