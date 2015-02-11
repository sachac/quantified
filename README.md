[![Build Status](https://travis-ci.org/sachac/quantified.svg?branch=master)](https://travis-ci.org/sachac/quantified) [![Coverage Status](https://coveralls.io/repos/sachac/quantified/badge.svg?branch=master)](https://coveralls.io/r/sachac/quantified?branch=master)

This is the source code for QuantifiedAwesome.com. It'll probably take a lot of tweaking to get it to work for you, but at least it's up here! =)

Instructions for setting up:

1. If you use Vagrant, the included Vagrantfile will set up a bunch of things for you. If you don't use Vagrant, look at the Vagrantfile for ideas on what to install.
2. Copy `config/database.yml.sample` to `database.yml` and customize it for your setup. Create the accompanying databases. If you would like to run your databases within the virtual machine, you may want to `apt-get install mysql-server mysql-client`. 
3. Copy `config/initializers/secret_token.rb.sample` to `config/initializers/secret_token.rb` and update it.

To start with an empty database, run `rake db:schema:load`.
Alternatively, you may want to run `rake db:setup`, which will set up
the database with an admin user. The admin user will have the password
"testpasswordgoeshere".

If you use Emacs, see `lisp/quantified.el`.

----

Other useful building steps:

rake bower:install

----

If you're creating your own instance, here's how to set up an admin user using *rails console*:

```ruby
u = User.create(email: 'test@example.com', username: 'test', password: 'testpassword', password_confirmation: 'testpassword')
u.role = 'admin'
u.save!
u.confirm!
```

----
Environment variables to set:

- Oauth2 for Google: https://github.com/zquestz/omniauth-google-oauth2
  - GOOGLE_CLIENT_ID
  - GOOGLE_CLIENT_SECRET
- Devise
  - DEVISE_SECRET_KEY