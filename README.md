This is the source code for QuantifiedAwesome.com. It'll probably take a lot of tweaking to get it to work for you, but at least it's up here! =)

Also, if you use Emacs, see lisp/quantified.el

----

If you're creating your own instance, here's how to set up an admin user using *rails console*:

```ruby
u = User.create(email: 'test@example.com', username: 'test', password: 'testpassword', password_confirmation: 'testpassword')
u.role = 'admin'
u.save!
u.confirm!
```
