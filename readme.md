# Slack Tracker

## How to get started!
1. Clone the repo at `repourl`.
2. Run `bundle install` inside the directory.
3. Visit `localhost:4567` (or where you pointed it to) and you should see `"Hello! Slack Tracker is running!"`.
4. Download and install a tunneler. (I used [ngrok](https://ngrok.com/) for this project.)
   1. Then run the tunneler in a separate terminal window. (Using ngrok, the command should look something like this: ` ./ngrok http 4567`)
5. Click "Create New App" in the [Your Apps](https://api.slack.com/apps) page of the Slack API website.
6. Complete the Dialog entering your App name and where you want the development deploy to take place.
7. On the next window, you should click "Slash Commands" under "Add features and functionality".
8. Click "Create New Command".
   - Command: "/slacktracker"
   - Request URL: This should be your HTTPS forwarding address using the tunneler followed by "/slack/tracker". (i.e. https://115b78c3.ngrok.io/slack/tracker).
   - Short Description: "Slack Tracker, helping you keep up with the time!"
   - Usage Hint: [start, stop, restart, help, total] (Note: this is an optional field)
   - Then Submit!
9. Join the Workspace that the app is connected to then type and submit "/slacktracker start" and you should see a response something like: `The clock started ticking at: 2019-04-11 22:52:51 UTC!`.

## Testing!
After completing steps 1 and 2 in the "How to getting started" section, you can run `rspec spec` when everything is installed and up and running.