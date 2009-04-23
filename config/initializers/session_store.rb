# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_active-calendar-engine_session',
  :secret      => '919b09ed8c598a28b288cf3b1361143d4cd2e00d3e8d1d8e31f02483500ce77ddc66435b9e4cabbe955bc2b22765e06c0415588a4e429173059a9024271c4a8f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
