#! /bin/sh
# file: functions.sh

source src/functions.sh

testThatPrintOptions()
{
  options=$(printOptions)
  assertEquals "$options" "[y/n Y/N]"
}

# load shunit2
. tests/shunit2