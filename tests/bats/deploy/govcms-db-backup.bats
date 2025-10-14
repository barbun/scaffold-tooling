#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030

load ../_helpers_govcms

@test "Database backup: defaults" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "No read replica hosts configured using default database."
  assert_equal "sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/app/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: with read replica available" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1
  mock_set_output "${mock_drush}" "table1\ntable2" 2

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS="dbreplicahost1"

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "Checking for read database availability..."
  assert_output_contains "Read replica database is available, using --database=read flag"
  assert_equal "sqlq show tables; --database=read" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "sql:dump --database=read --gzip --extra-dump=--no-tablespaces --result-file=/app/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: with read replica unavailable" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1
  mock_set_output "${mock_drush}" "" 2

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS="dbreplicahost1"

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "Checking for read database availability..."
  assert_output_contains "Read database not available, using default database."
  assert_equal "sqlq show tables; --database=read" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/app/web/sites/default/files/private/backups/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 3)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: non-production" {
  mock_drush=$(mock_command "drush")

  export LAGOON_ENVIRONMENT_TYPE=development
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "[skip]: Non-production environment."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: skip" {
  mock_drush=$(mock_command "drush")

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=1
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "[skip]: Skipping database backup."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: custom directory" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=/tmp/test
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "No read replica hosts configured using default database."
  assert_equal "sql:dump --gzip --extra-dump=--no-tablespaces --result-file=/tmp/test/pre-deploy-dump.sql" "$(mock_get_call_args "${mock_drush}" 2)"

  assert_output_contains "[success]: Completed successfully."
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

@test "Database backup: site not installed" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Failed"}' 1

  export LAGOON_ENVIRONMENT_TYPE=production
  export GOVCMS_BACKUP_DIR=
  export GOVCMS_SKIP_DATABASE_BACKUP=
  export MARIADB_READREPLICA_HOSTS=

  run scripts/deploy/govcms-db-backup >&3

  assert_output_contains "GovCMS Deploy :: Backup database"
  assert_output_contains "[fail]: Drupal is not installed or operational."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
} 
