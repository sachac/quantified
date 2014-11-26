This is the source code for QuantifiedAwesome.com. It'll probably take a lot of tweaking to get it to work for you, but at least it's up here! =)

You may want to rake db:setup, which will set up the database with an admin user. The admin user will have the password "testpasswordgoeshere".

Also, if you use Emacs, see lisp/quantified.el

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
