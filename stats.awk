# Copyright © 2010, Alexey Pisanko (apis72@gmail.com) All rights reserved.
#
# License: GPL 3/LGPL 3
#
# Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, 
# either express or implied. See the License for the specific language governing rights and limitations 
# under the License.
# ------------------------------------------------------------------------------------------------------- 
#
# Record format for 'git log --numstat' output
#
# --- begin ---
# commit 2394ae0e9883c8834f2e506786f1132ff694b655
# Author: Scrooge McDuck <scrooge@nowhere.com>
# Date:   Sun Dec 19 22:51:32 2010 -0500
#
#    fixed redirect issue
#
# 1	1	app/controllers/money_controller.rb
#
# --- end ---

BEGIN {
  COMMIT_TEXT = "commit"
  AUTHOR_TEXT = "Author:"
  DATE_TEXT = "Date:"
  AUTHOR_COUNT = 0
}

END {
  print_stats()
}
 
{
  parse_header()
  process_message()
  process_stats() 
}

function parse_header() {
  parse_commit_field()
  parse_author_field()
  parse_date_field()

  FS = " "
  get_line()
  if ( $0 != "" ) {
    fail()
  }
}

function parse_commit_field() {
  if (COMMIT_TEXT != $1) {
    fail()
  }
}

function parse_author_field() {
  FS = AUTHOR_TEXT
  get_line()
  if ("" == $2) {
    fail()
  }
  AUTHOR = $2
  sub(/^ */, "", AUTHOR)
}

function parse_date_field() {
  FS = DATE_TEXT
  get_line()
  if ("" == $2) {
    fail()
  }
}

function process_message() {
  get_line()
  while($0 != "") {
    get_line()
  }
}

function process_stats() {
  init_author_index()
  get_line()
  result = 1
  count = 0
  while($0 != "" && result == 1) {
    count++
    update_stats($1, $2)
    result = getline
  }
  AUTHOR_FILES[AUTHOR_INDEX] += count
  AUTHOR_COMMITS[AUTHOR_INDEX] ++
}

function update_stats(added, deleted) {
  if (added != "-") {
    AUTHOR_ADDED[AUTHOR_INDEX] += added
  }
  
  if (deleted != "-") {
    AUTHOR_DELETED[AUTHOR_INDEX] += deleted
  }
}

function init_author_index() {
  for (i = 0; i < AUTHOR_COUNT; i++) {
    if (AUTHORS[i] == AUTHOR) {
      AUTHOR_INDEX = i
      return
    }
  }

  AUTHORS[AUTHOR_COUNT] = AUTHOR
  AUTHOR_ADDED[AUTHOR_COUNT] = 0
  AUTHOR_DELETED[AUTHOR_COUNT] = 0
  AUTHOR_FILES[AUTHOR_COUNT] = 0
  AUTHOR_COMMITS[AUTHOR_COUNT] = 0
  AUTHOR_INDEX = AUTHOR_COUNT
  AUTHOR_COUNT++
}

function fail() {
  print "===>>> Script failed! <<<==="
  exit 1
}

function get_line() {
  if (getline != 1) {
    fail()
  }
}

function print_stats() {
  for (i = 0; i < AUTHOR_COUNT; i++) {
    print "Author:", AUTHORS[i]
    print "Insertions:", AUTHOR_ADDED[i]
    print "Deletions:", AUTHOR_DELETED[i]
    print "Files changed:", AUTHOR_FILES[i]
    print "Commits:", AUTHOR_COMMITS[i]
    print ""
  }
}

