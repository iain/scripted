# encoding: utf-8
#
# This example shows of parallel commands.
#
# The output should look something like:
#
#     ┌─────────┬─────────┬─────────┐
#     │ Command │ Runtime │ Status  │
#     ├─────────┼─────────┼─────────┤
#     │ sleep 1 │  1.061s │ success │
#     │ sleep 1 │  1.062s │ success │
#     │ sleep 1 │  1.064s │ success │
#     │ sleep 1 │  1.066s │ success │
#     │ sleep 1 │  1.064s │ success │
#     └─────────┴─────────┴─────────┘
#       Total runtime: 2.307s
#
# To run: rake examples:parallel

formatter :table

parallel do
  run "sleep 1"
  run "sleep 1"
end
parallel do
  run "sleep 1"
  run "sleep 1"
  run "sleep 1"
end
