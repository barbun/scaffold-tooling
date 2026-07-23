#!/usr/bin/env bats
# shellcheck disable=SC2002,SC2031,SC2030,SC2034,SC2155

load ../_helpers_govcms

################################################################################
#                               DEFAULTS                                       #
################################################################################

# Workflow: import
# dir: /app/config/default
@test "Config import: defaults" {
  mock_drush=$(mock_command "drush")

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: There is no configuration."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: retain
# dir: /app/config/default
@test "Config import: retain" {
  mock_drush=$(mock_command "drush")
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=retain

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: Workflow is not set to import."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
@test "Config import: import" {
  mock_drush=$(mock_command "drush")
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: There is no configuration."

  assert_equal 0 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
@test "Config import: default config" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="/tmp/nodir"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
# devdir: ./fixtures/config/dev
@test "Config import: dev config (production)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export LAGOON_ENVIRONMENT_TYPE="production"
  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[success]: Completed successfully."

  assert_equal 1 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: /app/config/default
# devdir: ./fixtures/config/dev
@test "Config import: dev config (nonprod)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export LAGOON_ENVIRONMENT_TYPE="development"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y --source=${CONFIG_DEV_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
# devdir: ./fixtures/config/dev
@test "Config import: both dirs available (production)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="production"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixures/config/default
# devdir: ./fixtures/config/dev
@test "Config import: both dirs available (nonprod)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="development"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "config:import -y --source=${CONFIG_DEV_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

################################################################################
#                            CONFIG_LOCAL_DIR                                  #
################################################################################

# Workflow: import
# dir: ./fixtures/config/default
# devdir: ./fixtures/config/dev
# localdir: ./fixtures/config/local
# Local environment with all three dirs present applies all three imports
# in order: default, dev, local. Local is partial and runs last.
@test "Config import: local config (local env, all dirs)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="local"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export CONFIG_LOCAL_DIR="tests/bats/deploy/fixtures/config/local"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[update]: Import local configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "config:import -y --source=${CONFIG_DEV_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal "config:import -y --source=${CONFIG_LOCAL_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 4)"
  assert_equal 4 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixtures/config/default
# devdir: ./fixtures/config/dev
# localdir: /tmp/nodir (missing)
# Local environment but no local dir on disk: behaves identically to a
# regular non-prod run (default + dev only).
@test "Config import: local config (local env, no local dir)" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="local"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export CONFIG_LOCAL_DIR="/tmp/nodir"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_output_not_contains "[update]: Import local configuration partially."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "config:import -y --source=${CONFIG_DEV_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixtures/config/default
# devdir: ./fixtures/config/dev
# localdir: ./fixtures/config/local
# Regression guard: development env must NOT pick up the local overlay even
# if the local directory is present and configured.
@test "Config import: local config not applied on development env" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="development"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export CONFIG_LOCAL_DIR="tests/bats/deploy/fixtures/config/local"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[update]: Import dev configuration partially."
  assert_output_contains "[success]: Completed successfully."

  assert_output_not_contains "[update]: Import local configuration partially."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal "config:import -y --source=${CONFIG_DEV_DIR} --partial" "$(mock_get_call_args "${mock_drush}" 3)"
  assert_equal 3 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# dir: ./fixtures/config/default
# devdir: ./fixtures/config/dev
# localdir: ./fixtures/config/local
# Production env: only the default import runs. Neither dev nor local
# overlays may be applied, regardless of CONFIG_LOCAL_DIR contents.
@test "Config import: local config not applied on production env" {
  mock_drush=$(mock_command "drush")
  mock_set_output "${mock_drush}" '{"bootstrap": "Successful"}' 1

  export GOVCMS_DEPLOY_WORKFLOW_CONFIG=import
  export LAGOON_ENVIRONMENT_TYPE="production"
  export CONFIG_DEFAULT_DIR="tests/bats/deploy/fixtures/config/default"
  export CONFIG_DEV_DIR="tests/bats/deploy/fixtures/config/dev"
  export CONFIG_LOCAL_DIR="tests/bats/deploy/fixtures/config/local"

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[update]: Import site configuration."
  assert_output_contains "[success]: Completed successfully."

  assert_output_not_contains "[update]: Import dev configuration partially."
  assert_output_not_contains "[update]: Import local configuration partially."

  assert_equal "config:import -y" "$(mock_get_call_args "${mock_drush}" 2)"
  assert_equal 2 "$(mock_get_call_num "${mock_drush}")"
}

# Workflow: import
# branch: update pattern
@test "Config import: upgrade branch" {
  mock_drush=$(mock_command "drush")
  export LAGOON_GIT_SAFE_BRANCH=internal-govcms-update-2-x-master

  run scripts/deploy/govcms-config-import >&3

  assert_output_contains "GovCMS Deploy :: Configuration import"
  assert_output_contains "[skip]: Configuration cannot be imported on update branches."
}
