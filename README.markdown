pacman
==

'Pacman' is a generic json injestor.
--

It's designed to be generic via usage of a 'mappings/foo.json' file, in which a specification of how the values of the source feed will be mapped to values in the destination feed.

---

###Usage:

You provide it with:

1. The url of a feed to injest
2. The name of a mappings file 'foo' that will be found in /mappings/foo.json
3. The key for the desired array to injest

For example:

`http://pacman.heroku.com?source_feed=rfstemp.heroku.com&mappings_name=rfs&key=fires`

***

###mappings/foo.json

A mappings file is a specification that will determine how the injested feed is treated.  It is a hash of the form:

`{
  "key" : keyspec,
  ... 
}`

There are several dimensions to this- perhaps a list of examples will make this clear:


"key" : "key"
:   This is the 'passthrough' usage.  The value of the key 'key' from the source feed will be placed into the destination feed, with the key 'key'.



"_key" : "key"
:   This will take the value of the key '_key' from the source feed and place it in the destination feed, with the key 'key'.



"key" : "attributes.key"
:   This will nest the value in the 'attributes' hash within the destination feed.[^1]



[^1]: In future, there may be a provision to specify this arbitrarily, but for now (given that this is space-time specific) we specify it explicitly.



"key" : {
  "delimiter" : " ",
  "destination_keys" : ["key1" , "key2" ]
}
:   This usage allows us to map a single key's value form the source feed to the value of multiple keys in the destination feed.  Let's imagine that the original feed has this key and value:

`"georss_point" : "130.125 32.521"`

We want to map this to lat/lon (as it so happens, within the 'attributes' hash), so the spec becomes:

`"georss_point" : {
  "delimiter" : " ",
  "destination_keys" : ["attributes.lat", "attributes.lon"]
}`



"key" : {
  "value_maps" : {
    true : "Yes",
    false : "No",
    "nil" : "No",
    "default" : "No"
  }
}
:   This usage takes care of situations where the values of keys require translation.  Note that the two cases of no data ("nil") as well as a default case may be allowed for.




