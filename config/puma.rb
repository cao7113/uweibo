app_root = File.expand_path("../..", __FILE__)
directory app_root
bind "unix://#{app_root}/tmp/puma.sock"
environment "production"
