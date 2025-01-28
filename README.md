# GBlog

GBlog is a site to visualize my odd method of taking notes and connecting thoughts.

I take plain text notes and push it to the Miki repo, whereupon an action is kicked off to recompile and publish this site.

## In development environment

### Run

```
rails s
```

### Compile database

Rake task to move note content from text files into a sqlite database.

```
rails pages:load
```

## Deploy

Run this command to copy files from iCloud directory to the `GBlog` repo:
```
rsync -avh --delete "source folder" "destination folder"
```

Run this command to populate the production database
```
RAILS_ENV=production rails pages:load
```

Push to github repo
```
git add .
git commit -m "FOO"
git push
```

SSH into web server
```
ssh redatavpn
```

Attach to screen, stop web server, refresh content, re-start web server
```
screen -ls gblog     # List screen sessions
screen -r gblog      # Attach to the gblog screen session
<stop server: ctrl-c>
git pull
RAILS_ENV=production rails s
<detach from screen: ctrl-a, d>
```

Reload site to ensure new content is present.