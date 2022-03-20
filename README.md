# Chronicle::Pinboard
[![Gem Version](https://badge.fury.io/rb/chronicle-pinboard.svg)](https://badge.fury.io/rb/chronicle-pinboard)

Extract your Pinboard bookmarks using the command line with this plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `pinboard` - Extractor for importing bookmarks

### Transformers
- `pinboard` - Transforms bookmarks into Chronicle Schema

## Usage

```sh
gem install chronicle-etl
chronicle-etl connectors:install pinboard

# You can get PINBOARD_ACCESS_TOKEN from https://pinboard.in/settings/password
# Extract pinboard bookmarks from the last 10 days
chronicle-etl --extractor pinboard --extractor-opts access_token:$PINBOARD_ACCESS_TOKEN --since 10d
```

