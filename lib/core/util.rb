require 'fileutils'
require 'paint'
require 'json'
require 'http'
require 'digest'
require 'io/console'
require_relative 'constants'

#
# Utility methods
#
module Rise
  module Util

    def self.is_first_run?
      !File.directory?(File.join(Dir.home, '.rise'))
    end

    def self.setup
      puts Paint["Detected first time setup, creating necessary files...", :blue]
      FileUtils.mkdir(RISE_DATA_DIR)
      FileUtils.mkdir(File.join(RISE_DATA_DIR, 'auth'))

      # Get the input from the user
      print Paint["1. Log in\n2. Sign up\n  > ", :bold]
      while (choice = gets.chomp!)
        if choice == "1"
          login
          break
        elsif choice == "2"
          signup
          break
        else
          puts Paint["Please type `1` or `2`", :red]
          next
        end
      end

    end

  end
end

# We generally don't want to use these anywhere else, so theyre out of the scope of the module
def login

  print "\nEmail: "
  email = gets.chomp!
  print "\nPassword: "
  password = STDIN.noecho(&:gets)
  hash = Digest::SHA256.base64digest(password).gsub('/', '')  # this means it's not REALLY SHA256 but it's very very close (it screws with the sinatra mappings)
  res = HTTP.post("http://#{DOMAIN}:#{AUTH_PORT}/login?email=#{email}&hash=#{hash}")
  if res.code == 200
    puts Paint["\nLogin successful!", :green, :bold]
  else
    puts Paint["\nLogin failed!", :red, :bold]
    puts "Printing error: #{res.code}: #{res.body}"
  end
end

def signup
  print "\nEmail: "
  email = gets.chomp!
  print "\nPassword: "
  password = STDIN.noecho(&:gets)
  hash = Digest::SHA256.base64digest(password).gsub('/', '')
  res = HTTP.post("http://#{DOMAIN}:#{AUTH_PORT}/signup?email=#{email}&hash=#{hash}")
  if res.code == 200
    puts Paint["\nSignup successful!", :green, :bold]
    File.open(File.join(RISE_DATA_DIR, 'auth', 'creds.json'), 'a') do |f|
      creds_hash = {
        'email' => email,
        'hash'  => hash
      }
      f.puts(creds_hash.to_json)
    end
  elsif res.code == 409  # user already exists
    puts Paint["\nSignup failed!", :red, :bold]
    puts "Printing error: #{res.body}"
  end
end
