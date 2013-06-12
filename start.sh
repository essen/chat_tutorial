#!/bin/sh
erl -pa ebin deps/*/ebin -boot start_sasl -s websocket \
    -eval "io:format(\"Point your browser at http://localhost:8080/ to use a simple websocket client~n\")."

