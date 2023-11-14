## 2.0.0

- [FEATURE] Upgrade to Webflow API v2 😍 @vfonic
- [BREAKING] This version brings many breaking changes! All returned hashes' keys are symbolized. Webflow item fields are now located under `:fieldData` key in the hash: `client.item(collection_id, item_id).dig(:fieldData, :name)` 😍 @vfonic
- [BREAKING] Check `lib/webflow/client.rb` for the full API.

## 1.2.1

- [FEATURE] Handle Problems in Validation errors https://github.com/penseo/webflow-ruby/pull/14 https://github.com/penseo/webflow-ruby/pull/16 😍 @vfonic @sega

## 1.2.0

- [FEATURE] Add patch support for updating items https://github.com/penseo/webflow-ruby/issues/10 😍 @ukd1

## 1.1.0

- [FEATURE] Allow passing a block to `items` that yields the results by page https://github.com/penseo/webflow-ruby/issues/9 😍 @emilesilvis
- [FEATURE] Handle Webflow live feature https://github.com/penseo/webflow-ruby/pull/8 😍 @emilesilvis

## 1.0.0

- [BREAKING] Raise errors when status > 200, see also https://github.com/penseo/webflow-ruby/pull/7 😍 @sega

## 0.7.0

- [FEATURE] Configuration class to store api token https://github.com/penseo/webflow-ruby/pull/6 😍 @mateuscruz

## 0.6.0

- [CHANGE] Use pure ruby dependencies

## 0.5.0

- [FEATURE] Pagination https://github.com/penseo/webflow-ruby/pull/2 😍 @cohesiveneal
