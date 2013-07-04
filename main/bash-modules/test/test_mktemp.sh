#!/bin/bash

set -ue

__IMPORT__BASE_PATH=../src/bash-modules
. ../src/import.sh log unit mktemp

setUp() {
  unset TMPDIR
}

###############################################
# Test cases

test_mktemp_without_options() {
  FOO=`mktemp`
  assert "File was not created by mktemp." [ -f "$FOO" ]
  assert "Temporary file must be placed in /tmp." [[ "$FOO" == "/tmp/*" ]]
  rm -f "$FOO"
}

test_mktemp_with_u_option() {
  FOO=`mktemp -u`
  assert "File must not be created by mktemp with -u option." [ !  -f "$FOO" ]
  assert "Temporary file must be placed in /tmp." [[ "$FOO" == "/tmp/*" ]]
}

test_mktemp_with_dry_run_option() {
  FOO=`mktemp --dry-run`
  assert "File must not be created by mktemp with -u option." [ !  -f "$FOO" ]
  assert "Temporary file must be placed in /tmp." [[ "$FOO" == "/tmp/*" ]]
}

test_mktemp_with_dry_run_option() {
  FOO=`mktemp --dry-run`
  assert "File must not be created by mktemp with --dry-run option." [ !  -f "$FOO" ]
  assert "Temporary file must be placed in /tmp." [[ "$FOO" == "/tmp/*" ]]
}

test_mktemp_with_template() {
  FOO=`mktemp /var/tmp/foooXXXXXXXXX.bar`
  assertNotEqual "$FOO" "/var/tmp/foooXXXXXXXXX.bar" "XXXXX in template is not replaced by random string."
  assert "File was not created by mktemp." [ -f "$FOO" ]
  assert "Temporary file must be placed in /var/tmp in this case." [[ "$FOO" == "/var/tmp/*" ]]
  rm -f "$FOO"
}

test_mktemp_with_d_option() {
  FOO=`mktemp -d`
  assert "Directory was not created by mktemp." [ -d "$FOO" ]
  rm -rf "$FOO"
}

test_mktemp_with_t_option() {
  FOO=`mktemp -t /var/tmp/foooXXXXXXXXX.bar`
  assert "File was not created by mktemp." [ -f "$FOO" ]
  assert "Temporary file must be placed in /tmp in this case." [[ "$FOO" == "/tmp/foo*" ]]
  rm -f "$FOO"
}

test_mktemp_with_tmpdir_option() {
  FOO=`mktemp --tmpdir=/var/tmp /tmp/foooXXXXXXXXX.bar`
  assert "File was not created by mktemp." [ -f "$FOO" ]
  assert "Temporary file must be placed in /var/tmp in this case." [[ "$FOO" == "/var/tmp/foo*" ]]
  rm -f "$FOO"
}


mktemp_test_file_worker() {
  local WORKER_NUMBER="$1"
  local NUMBER_OF_FILES="$2"
  shift 2

  local FILES=( )
  for((I=0; I<NUMBER_OF_FILES; I++))
  do
    local FILE=`mktemp "$@"`
    echo "$WORKER_NUMBER:$I" > "$FILE"
    FILES[${#FILES[@]}]="$FILE"
  done

  for((I=0; I<NUMBER_OF_FILES; I++))
  do
    assertEqual `cat "${FILES[I]}"` "$WORKER_NUMBER:$I" "Incorrect content of file \"${FILES[I]}\"."
    rm -f "${FILES[I]}"
  done
}

# Heavy test case. Remove DISABLED_ to enable it.
DISABLED_test_mktemp_in_parallel_mode_for_files() {
  mktemp_test_file_worker 1 200 /tmp/test_mktemp_in_parallel_mode_for_files.XXX &
  mktemp_test_file_worker 2 200 /tmp/test_mktemp_in_parallel_mode_for_files.XXX &
  mktemp_test_file_worker 3 200 /tmp/test_mktemp_in_parallel_mode_for_files.XXX &
  mktemp_test_file_worker 4 200 /tmp/test_mktemp_in_parallel_mode_for_files.XXX
  wait
}


mktemp_test_dir_worker() {
  local WORKER_NUMBER="$1"
  local NUMBER_OF_DIRS="$2"
  shift 2

  local DIRS=( )
  for((I=0; I<NUMBER_OF_DIRS; I++))
  do
    local DIR=`mktemp -d "$@"`
    echo "$WORKER_NUMBER:$I" >"$DIR"/foo.txt
    DIRS[${#DIRS[@]}]="$DIR"
  done

  for((I=0; I<NUMBER_OF_DIRS; I++))
  do
    assertEqual `cat "${DIRS[I]}"/foo.txt` "$WORKER_NUMBER:$I" "Incorrect content of file in directory \"${DIRS[I]}\"."
    rm -rf "${DIRS[I]}"
  done
}

# Heavy test case. Remove DISABLED_ to enable it.
DISABLED_test_mktemp_in_parallel_mode_for_dirs() {
  mktemp_test_dir_worker 1 200 /tmp/test_mktemp_in_parallel_mode_for_dirs.XXX &
  mktemp_test_dir_worker 2 200 /tmp/test_mktemp_in_parallel_mode_for_dirs.XXX &
  mktemp_test_dir_worker 3 200 /tmp/test_mktemp_in_parallel_mode_for_dirs.XXX &
  mktemp_test_dir_worker 4 200 /tmp/test_mktemp_in_parallel_mode_for_dirs.XXX
  wait
}

run_test_cases "$@"
