#!/bin/bash
#
# Copyright (c) 2009 Volodymyr M. Lisivka <vlisivka@gmail.com>, All Rights Reserved
#
# This file is part of bash-modules (http://trac.assembla.com/bash-modules/).
#
# bash-modules is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
#
# bash-modules is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with bash-modules  If not, see <http://www.gnu.org/licenses/>.

[ "${__renice__DEFINED:-}" == "yes" ] || {
  __renice__DEFINED="yes"

  if [ "${1:-}" == '--usage' -o "${1:-}" == '--summary' ]
  then

    renice_summary() {
      echo "Alter priority of current shell to make it low priority task"
    }

    renice_usage() {
      echo '
    source import.sh renice		Change prirority of current shell to 19 (lowest)
'
    }
  else
    # Run this script as low priority task
    renice 19 -p $$ >/dev/null
  fi
}
