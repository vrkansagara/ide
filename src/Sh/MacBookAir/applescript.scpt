-- Applications > Utilities
-- Command + R
tell application "System Events"
  repeat with i from 1 to infinity
    tell application "Microsoft Teams" to activate
    delay 60 -- Sets delay to 1 minute (60 seconds)
    tell application "Finder" to activate
  end repeat
end tell
