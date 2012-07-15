# http://stackoverflow.com/questions/3079797/xml-builder-in-rails-wrong-number-of-arguments-bug-that-i-just-cant-trace
class String
  def fast_xs_absorb_args(*args); fast_xs; end
  alias_method :to_xs, :fast_xs_absorb_args
end
