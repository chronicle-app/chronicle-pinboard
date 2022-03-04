# Chronicle::Pinboard

Pinboard plugin for [chronicle-etl](https://github.com/chronicle-app/chronicle-etl)

## Available Connectors
### Extractors
- `pinboard` - Extractor for importing bookmarks

### Transformers
- `pinboard` - Transforms bookmarks into Chronicle Schema

## Usage

```sh
gem install chronicle-etl
chronicle-etl connectors:install pinboard

# get PINBOARD_ACCESS_TOKEN from https://pinboard.in/settings/password
chronicle-etl --extractor pinboard --extractor-opts access_token:$PINBOARD_ACCESS_TOKEN --since 2022-02-07
```

