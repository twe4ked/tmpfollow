namespace :db do
  desc 'Auto-migrate the database (destroys data)'
  task :migrate => :environment do
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade => :environment do
    DataMapper.auto_upgrade!
  end
end

# This task is called by the Heroku scheduler add-on
desc 'Unfollow all users that need to be unfollowed today'
task :unfollow_users => :environment do
  # find all users that need to be unfollowed today
  unfollows = Unfollow.all(:date => Date.today)

  puts "Unfollowing #{unfollows.size} users..."

  unfollows.each do |unfollow|
    client = Twitter::Client.new(
      :oauth_token        => unfollow.oauth_token,
      :oauth_token_secret => unfollow.oauth_token_secret
    )

    # unfollow user
    client.unfollow unfollow.user

    # TODO: catch errors of the user is unfollowed twice
    # notify the user of the unfollow
    client.direct_message_create client.current_user.id, "tmp/follow has unfollowed @#{unfollow.user} for you."

    puts "Unfollowed '#{unfollow.user}'"

    # remove record
    unfollow.destroy
  end

  puts 'Done.'
end

task :environment do
  require './tmpfollow'
end
