#!/usr/bin/env bats

load test_helper

setup() {
  setup_test_directory
  setup_elastic_migrate
}

teardown() {
  teardown_test_directory
  teardown_elastic_migrate
}


@test "[elastic-migrate DOWN] should show help with the short-form help option" {
  run elastic-migrate down -h
  assert_success
  assert_line "Usage: elastic-migrate-down [options] [version]"
}

@test "[elastic-migrate DOWN] should show help with the long-form help option" {
  run elastic-migrate down --help
  assert_success
  assert_line "Usage: elastic-migrate-down [options] [version]"
}

@test "[elastic-migrate DOWN] should give error when missing host" {
  export ELASTICSEARCH_HOST_BAK=$ELASTICSEARCH_HOST
  unset ELASTICSEARCH_HOST
  run elastic-migrate down
  assert_failure
  assert_line "Error: Must provide host"
  export ELASTICSEARCH_HOST=$ELASTICSEARCH_HOST_BAK
  unset ELASTICSEARCH_HOST_BAK
}

@test "[elastic-migrate DOWN] should give error when given a bad hostname" {
  export ELASTICSEARCH_HOST_BAK=$ELASTICSEARCH_HOST
  export ELASTICSEARCH_HOST=badhost:9200
  run elastic-migrate down
  assert_failure
  assert_line "Error connecting to host"
  export ELASTICSEARCH_HOST=$ELASTICSEARCH_HOST_BAK
  unset ELASTICSEARCH_HOST_BAK
}

@test "[elastic-migrate DOWN] should output nothing to do when no migrations are present" {
  run elastic-migrate down
  assert_success
  assert_line "Nothing to do."
}

@test "[elastic-migrate DOWN] should output a target version when given" {
  setup_test_migrations
  elastic-migrate up
  refresh_index
  run elastic-migrate down 20181013140207
  assert_success
  assert_line "Migrating version=20181013140207 remove_bar"
  assert_line "Migrating version=20181013140224 remove_foo"
}

@test "[elastic-migrate DOWN] should output the default target version (down one) when missing" {
  setup_test_migrations
  elastic-migrate up
  refresh_index
  run elastic-migrate down
  assert_success
  assert_line "Migrating version=20181013140224 remove_foo"
}

@test "[elastic-migrate DOWN] should output nothing to do if no migrations have been run on host" {
  setup_test_migrations
  run elastic-migrate down
  assert_success
  assert_line "Nothing to do."
}

@test "[elastic-migrate DOWN] should migrate to the target versions when given" {
  setup_test_migrations
  elastic-migrate up
  refresh_index
  MIGRATED_COUNT=$(curl -s -X GET $ELASTICSEARCH_HOST/$ELASTIC_MIGRATE_MIGRATIONS_INDEX_NAME/_count\?q=\* | jq '.count')
  assert_equal 4 $MIGRATED_COUNT

  run elastic-migrate down 20181013140207
  refresh_index
  NEW_MIGRATED_COUNT=$(curl -s -X GET $ELASTICSEARCH_HOST/$ELASTIC_MIGRATE_MIGRATIONS_INDEX_NAME/_count\?q=\* | jq '.count')
  assert_equal 2 $NEW_MIGRATED_COUNT
  assert_success
}
@test "[elastic-migrate DOWN] should migrate down one version when version is not given" {
  setup_test_migrations
  elastic-migrate up
  refresh_index
  MIGRATED_COUNT=$(curl -s -X GET $ELASTICSEARCH_HOST/$ELASTIC_MIGRATE_MIGRATIONS_INDEX_NAME/_count\?q=\* | jq '.count')
  assert_equal 4 $MIGRATED_COUNT

  run elastic-migrate down
  refresh_index
  NEW_MIGRATED_COUNT=$(curl -s -X GET $ELASTICSEARCH_HOST/$ELASTIC_MIGRATE_MIGRATIONS_INDEX_NAME/_count\?q=\* | jq '.count')
  assert_equal 3 $NEW_MIGRATED_COUNT
  assert_success
}
