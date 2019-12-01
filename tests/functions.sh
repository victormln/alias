#! /bin/sh
# file: functions.sh

source ../src/functions.sh

testThatPrintOptions()
{
  options=$(printOptions)
  assertEquals "$options" "[y/n Y/N]"
}

# load shunit2
. /usr/local/bin/shunit2