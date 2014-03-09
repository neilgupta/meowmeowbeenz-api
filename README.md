meowmeowbeenz-api
=============

http://github.com/neilgupta/meowmeowbeenz-api

MeowMeowBeenz let's you say how much you like, who you like, when you like, all from a standard non-Boost Mobile phone!

This project provides a restful API for powering the meowmeowbeenz mobile app.

## Progress

So far, this api handles signing up, logging in, rating, and searching users.

## TODO

The following features still need to be added:

* Send push notifications to mobile devices when they are given meowmeowbeenz or when their meowmeowbeenz level changes. I am thinking of using Amazon SNS ([with j7w1 gem](https://github.com/condor/j7w1)) for push notifications.
* Tests

If there are any features that should be added to this list, create a [new issue](https://github.com/neilgupta/meowmeowbeenz-api/issues).

## Getting Started

1. Make sure you have Ruby 2 and Postgres 9 installed (`ruby -v && postgres --version`)
2. Clone this repo (`git clone git@github.com:neilgupta/meowmeowbeenz-api.git`)
3. Copy `config/database.yml.sample`, enter your db username and password, and save as `config/database.yml`
4. Copy `env.sample`, fill out config variables, and save as `.env`
5. Run the following commands:

```ruby
bundle install
rake db:create
rake db:migrate
foreman start -p 3000
```

Access the documentation at http://localhost:3000/docs and the API at http://localhost:3000/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

The idea comes from NBC's *Community* Season 5, Episode 8: "[App Development and Condiments](http://en.wikipedia.org/wiki/App_Development_and_Condiments)"

It is a brilliant episode, check it out!

## Author

Neil Gupta https://github.com/neilgupta && http://metamorphium.com

## License

The MIT License (MIT) Copyright (c) 2014 Neil Gupta. See [LICENSE.txt](https://raw.github.com/neilgupta/meowmeowbeenz-api/master/LICENSE.txt)