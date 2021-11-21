#! /bin/sh
# file: functions.sh

source src/functions.sh

testThatPrintOptions()
{
  options=$(printOptions)
  assertEquals "$options" "[y/n Y/N]"
}

testThatAnAliasIsCreated() {
  addAlias
  echo "test"
}

# load shunit2
. tests/shunit2