# README

This is the OpenWeather Application I build end to end

The way I structured this application was as follows:

DB layer:

* I am currently using a table for countries mapped to the country code (2 digit) that is required by the OpenWeather API.  To do this, I downloaded a JSON file of all the mappings, created a table as a migration task, and then `rails db:migrate` in order to create the table, and then wrote a seed.rb task to seed the table with the data from the JSON.  To do this, I ran `rake db:seed`, and filled the DB with all the information needed

* I also added a table for weather that had already been retrieved.  This is the "caching" mechanism that was referred to in the practicum.  Rather than bog down the API I am calling with repeated requests for weather, I get the data from one API call, get the current time that this request was made, and write this to the table.  Next time someone requests the same city/country pair, they can refer back to the table and if the original written request in that table was made < 10 minutes ago, we just serve the data from our table, since 10 minutes is the recommendation given by the API spec to get accurate weather data for a city.  If the request was made > 10 minutes ago, we do a fresh pull from the API, and update our table value with this
    * I realize there's a bug with this that I overlooked with city name (as I was typing this out), since there can be multiple cities of the same name in different countries, and my code didn't address that.  I would improve the design by writing the city as a combination of city/country to the database in the future.  This is something that can be easily done.  This is not actually a bug in terms of serving this data to the user, but more that the performance will be impacted in terms of caching.


Rails Backend:

* I created routes in routes.rb, one that links to the list of countries that can be served as JSON, and one that will serve all the weather data for cities.  These link to corresponding methods in the controller
* I created a model that is not an extension of ActiveRecord, but a physical model for Weather that actually allows me to abstract out all the underlying functionality to the controller.  This does the heavy lifting, the pulling of fields, the conversion of some fields (kelvin to farenheit temperatures, and m/s to mph for wind speed), adding of some fields like a meaningful verbiage for wind speed, etc.
* The control mostly does database manipulation for caching, as well as handles HTTP errors and renders the correct output in the correct cases
* My strategy was to minimize the amount of computation that the backend did, and abstract EVERYTHING into REST endpoints that would serve only the data requested, when requested

Javascript Frontend:

* I did this entirely in Backbone.js because it was familiar enough to me to install quickly and work with without the rampup of limited NPM/React dependency hell knowledge that I have.  I could have also done this in React, but Backbone was quicker.
* Backbone Models stored both the state of the city/country being requested in the form, as well as the latest data for the requested weather
* Backbone Views render out the search form and weather template and have actions based on city/country changes, submit button clicks, etc
* The frontend does all the heavy lifting in terms of user rendering, because it is generally cheaper in cloud computing to push that onto the client computer and not rack up server charges due to full out backend rendering

UX:
* This was sorely lacking, but I did my best with CSS and choosing a background image of (Crater Lake, OR)? to signify my own personal flavor and roots in the Pacific Northwest

AWS:
* This was absolutely not part of the spec, but I did this as an exercise to push my own knowledge a little bit.  I deployed this application to two t2.micro EC2 instances in 2 availability zones and added an elastic load balancer to balance the load between the two.  ELB runs as round-robin as far as I understand, and I put in a last minute hack to display the instance ID that the page is being served from.  Rails usually runs on port 3000, so ELB actually allows me to route traffic into port 80 by default, and forward that to 3000, so the user doesn't have to enter the ugly :3000 at the end of the URL.


Things I would change/improve in this application:
* Fix the bug I mentioned above that impacts caching because there are multiple cities with the same name
* Better UX design, but then again, that's not what I do day to day :)
* Implement concurrency handling on these DBs a bit more
* Add options to choose degrees celsius for the user, based on geographic location
* To further that point, actually render out the weather information in the correct units based on the user's country
* Add a Google Maps plugin showing the location on a map where the city is