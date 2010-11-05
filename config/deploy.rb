$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require "rvm/capistrano"
require "bundler/capistrano"

# = Settings

set :user, "ludo"
set :use_sudo, false

# == RVM
set :rvm_ruby_string, 'ruby-1.8.7@accumulator'

# == Bundler
set :bundle_dir, "" # Do not use --path option, just put them in rvm's gem location

# = Application

set :application, "accumulator"
set :deploy_to, "/home/#{user}/apps/ruby/#{application}"

# = Repository

set :scm, :git
set :repository, "git@git.cubicphuse.nl:accumulator.git"

# = Servers

role :app, "cubicphuse.nl"
role :db, "cubicphuse.nl", :primary => true
role :web, "cubicphuse.nl"

# = Tasks

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end
end