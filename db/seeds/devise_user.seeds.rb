after :roles do
  puts '==> Creating the \'god user\'...'

# Deletes all existing records.
  User.delete_all

# Restarts ids to 1.
  ActiveRecord::Base.connection.reset_pk_sequence!('users')

# Content.
  User.create(email: 'god@example.com', username: 'divinity', first_name: 'God', last_name: 'System',
              maiden_name: 'User', role_id: Role.find_by_key('god').id, password: 'password',
              confirmed_at: Time.now, sign_in_count: 0)
end
