puts '==> Filling the \'roles\' table...'

# Deletes all existing records.
Role.delete_all

# Restarts ids to 1.
ActiveRecord::Base.connection.reset_pk_sequence!('roles')

# Content.
Role.create(name: 'God', key: 'god', description: 'Super administrador del sistema. Tiene acceso a todo y superpoderes.',
            scope: 0)
Role.create(name: 'Default', key: 'default', description: 'Rol default del sistema.', scope: 0)
