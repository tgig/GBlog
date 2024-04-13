# GBlog

GBlog is a site to visualize my odd method of taking notes and connecting thoughts.

I take plain text notes and push it to the Miki repo, whereupon an action is kicked off to recompile and publish this site.

## Run

```
rails s
```

## Compile database

Rake task to move note content from text files into a sqlite database.

```
rails pages:load
```

## Deploy

Content is automatically deployed when a push to `main` branch happens

```
git checkout main
git push
```
