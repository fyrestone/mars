#!/bin/bash
set -e
if [ -n "$WITH_CYTHON" ]; then
  mkdir -p build
  export POOL_START_METHOD=forkserver

  retry -n 20 -g INTERNALERROR pytest $PYTEST_CONFIG --forked mars/tests mars/core/graph
  mv .coverage build/.coverage.non-oscar.file

  retry -n 20 -g INTERNALERROR pytest $PYTEST_CONFIG --forked mars/oscar
  mv .coverage build/.coverage.oscar_ctx.file

  coverage combine build/ && coverage report
fi
if [ -z "$NO_COMMON_TESTS" ]; then
  mkdir -p build
  pytest $PYTEST_CONFIG mars/remote mars/storage mars/lib
  mv .coverage build/.coverage.tileable.file

  pytest $PYTEST_CONFIG --forked --ignore mars/tensor --ignore mars/dataframe \
    --ignore mars/learn --ignore mars/remote mars
  mv .coverage build/.coverage.main.file
  coverage combine build/ && coverage report

  export DEFAULT_VENV=$VIRTUAL_ENV
  source testenv/bin/activate
  pytest --timeout=1500 mars/tests/test_session.py mars/lib/filesystem/tests/test_filesystem.py
  if [ -z "$DEFAULT_VENV" ]; then
    deactivate
  else
    source $DEFAULT_VENV/bin/activate
  fi
fi
