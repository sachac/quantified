require 'atom/collection'

# methods to make writing commandline Atom tools more convenient

module Atom::Tools
  # fetch and parse a Feed URL, returning the entries found
  def http_to_entries url, complete_feed = false, http = Atom::HTTP.new
    feed = Atom::Feed.new url, http

    if complete_feed
      feed.get_everything!
    else
      feed.update!
    end

    feed.entries
  end

  # parse a directory of entries
  def dir_to_entries path
    raise ArgumentError, "#{path} is not a directory" unless File.directory? path

    Dir[path+'/*.atom'].map do |e|
      Atom::Entry.parse(File.read(e))
    end
  end

  # parse a Feed on stdin
  def stdin_to_entries
    Atom::Feed.parse($stdin).entries
  end

  # POSTs an Array of Atom::Entrys to an Atom Collection
  def entries_to_http entries, url, http = Atom::HTTP.new
    coll = Atom::Collection.new url, http

    entries.each { |entry| coll.post! entry }
  end

  # saves an Array of Atom::Entrys to a directory
  def entries_to_dir entries, path
    if File.exists? path
      raise "directory #{path} already exists"
    else
      Dir.mkdir path
    end

    entries.each do |entry|
      e = entry.to_s

      new_filename = path + '/0x' + MD5.new(e).hexdigest[0,8] + '.atom'

      File.open(new_filename, 'w') { |f| f.write e }
    end
  end

  # dumps an Array of Atom::Entrys into a Feed on stdout
  def entries_to_stdout entries
    feed = Atom::Feed.new

    entries.each do |entry|
      puts entry.inspect
      feed.entries << entry
    end

    puts feed.to_s
  end

  # turns a collection of Atom Entries into an Array of Atom::Entrys
  #
  # source: a URL, a directory or "-" for an Atom Feed on stdin
  # options:
  #   :complete - whether to fetch the complete logical feed
  #   :user - username to use for HTTP requests (if required)
  #   :pass - password to use for HTTP requests (if required)
  def parse_input source, options
    entries = if source.match /^http/
             http = Atom::HTTP.new

             setup_http http, options

             http_to_entries source, options[:complete], http
           elsif source == '-'
             stdin_to_entries
           else
             dir_to_entries source
           end

    if options[:verbose]
      entries.each do |entry|
        puts "got #{entry.title}"
      end
    end

    entries
  end

  # turns an Array of Atom::Entrys into a collection of Atom Entries
  #
  # entries: an Array of Atom::Entrys pairs
  # dest: a URL, a directory or "-" for an Atom Feed on stdout
  # options:
  #   :user - username to use for HTTP requests (if required)
  #   :pass - password to use for HTTP requests (if required)
  def write_output entries, dest, options
    if dest.match /^http/
      http = Atom::HTTP.new

      setup_http http, options

      entries_to_http entries, dest, http
    elsif dest == '-'
      entries_to_stdout entries
    else
      entries_to_dir entries, dest
    end
  end

  # set up some common OptionParser settings
  def atom_options opts, options
    opts.on('-u', '--user NAME', 'username for HTTP auth') { |u| options[:user] = u }

    opts.on_tail('-h', '--help', 'show this usage statement') { |h| puts opts; exit }

    opts.on_tail('-p', '--password [PASSWORD]', 'password for HTTP auth') do |p|
      options[:pass] = p
    end
  end


  # obtain a password from the TTY, hiding the user's input
  # this will fail if you don't have the program 'stty'
  def obtain_password
    i = o = File.open('/dev/tty', 'w+')

    o.print 'Password: '

    # store original settings
    state = `stty -F /dev/tty -g`

    # don't echo input
    system "stty -F /dev/tty -echo"

    p = i.gets.chomp

    # restore original settings
    system "stty -F /dev/tty #{state}"

    p
  end

  def setup_http http, options
    if options[:user]
      http.user = options[:user]

      unless options[:pass]
        options[:pass] = obtain_password
      end

      http.pass = options[:pass]
    end
  end
end
