# Astria Ruby Client

An unofficial Ruby client for the [Astria API](https://astria.ai).

## Requirements

- Ruby: MRI > 3.2

## Installation

You can install the gem manually:

```shell
gem install astria-ruby
```

Or use Bundler and define it as a dependency in your Gemfile:

```ruby
gem 'astria-ruby', '~> 0.0.1'
```

## Documentation

### Relevant links

- [`astria-ruby` RDocs](https://www.rubydoc.info/gems/astria/).
- [Astria AI documentation](https://www.astria.ai/api/docs).

### Usage

## Creating a client

```ruby
client = Astria::Client.new(base_url: "https://api.astria.ai", access_token: "a1b2c3")
```

### Examples

Be sure to require the gem before trying any of the examples:

```ruby
require 'astria'
```

#### Authentication

```ruby
client = Astria::Client.new(access_token: "a1b2c3")
```

#### /tunes endpoint

##### GET /tunes

> Get a list of all fine-tunes
> `curl -X GET -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes
> [array of finetunes...]

```ruby
response = client.tunes.get         # execute the call
response.data                       # extract the relevant data from the response or

or:

client.tunes.get.data               # execute the call and get the data in one line
```

##### POST /tunes

If you would like to experiment with the API for testing purposes free, use branch=fast - This is will return hard-coded prompt results within a minute

Branch possible values: sd15, sd21, protogen34, openjourney2

`callback` is a URL that will be called when the fine-tune is done processing. The callback is a POST request where the body contains the tune object. Once the fine-tune is done processing, prompts will start processing.

`steps` - training steps is also an optional parameter which we recommend leaving out in order to allow better defaults set by the system.

`face_crop` - Enhanced face cropping. Optional. Defaults to accounts settings

`base_tune_id` - BETA. Optional. Training on top of former fine-tune or a different baseline model

Note this request is a multi-part encoded form request, i.e: not JSON

```
Example with cURL and nested prompts
curl -X POST -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes \
          -F tune[callback]="https://optional-callback-url.com/webhooks/astria?user_id=1&tune_id=1" \
          -F tune[title]="my portrait" \
          -F tune[branch]="fast" \
          -F tune[name]=man \
          -F tune[token]=sks \
          -F "tune[prompts_attributes][0][text]=sks man on space circa 1979 on cover of time magazine" \
          -F tune[prompts_attributes][0][callback]="https://optional-callback-url.com/webhooks/astria?user_id=1&prompt_id=1&tune_id=1" \
          -F "tune[images][]=@1.jpg" \
          -F "tune[images][]=@2.jpg" \
          -F "tune[images][]=@3.jpg" \
          -F "tune[images][]=@4.jpg"
Example with cURL with image_urls
curl -X POST -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes \
          -F tune[callback]="https://optional-callback-url.com/to-your-service-when-ready" \
          -F tune[title]="grumpy cat" \
          -F tune[branch]="fast" \
          -F tune[name]=cat \
          -F tune[token]=sks \
          -F "tune[image_urls][]=https://i.imgur.com/HLHBnl9.jpeg" \
          -F "tune[image_urls][]=https://i.imgur.com/HLHBnl9.jpeg" \
          -F "tune[image_urls][]=https://i.imgur.com/HLHBnl9.jpeg" \
          -F "tune[image_urls][]=https://i.imgur.com/HLHBnl9.jpeg"
Example with cURL, image_urls and nested prompts with JSON
{
  "tune": {
    "name": "cat",
    "branch": "fast",
    "callback": "https://optional-callback-url.com/to-your-service-when-ready",
    "image_urls": [
      "https://i.imgur.com/HLHBnl9.jpeg",
      "https://i.imgur.com/HLHBnl9.jpeg",
      "https://i.imgur.com/HLHBnl9.jpeg",
      "https://i.imgur.com/HLHBnl9.jpeg"
    ],
    "title": "grumpy cat with prompts",
    "prompts_attributes": [
      {
        "text": "sks cat in space circa 1979 French illustration"
      },
      {
        "text": "sks cat getting into trouble viral meme"
      }
    ]
  }
}
curl -X POST -H"Content-Type: application/json" -H "Authorization: Bearer $API_KEY" --data @prompt.json https://api.astria.ai/tunes
Get one fine-tune
Note that ckpt_url is only available after the fine-tune is done processing, and is a pre-signed URL which expires after 60 minutes.

curl -X GET -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes/1
{
  "id": 1,
  "images": [
    "http://assets.astria.ai/1.jpg",
    "http://assets.astria.ai/2.jpg",
    "http://assets.astria.ai/3.jpg",
    "http://assets.astria.ai/4.jpg"
  ],
  "name": "man",
  "steps": null,
  "ckpt_url": "https://....",
  "created_at": "2022-10-06T14:06:09.088Z",
  "updated_at": "2022-10-06T14:06:09.139Z",
  "url": "http://api.astria.ai/tunes/26.json"
}
Delete one fine-tune
curl -X DELETE -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes/1
Prompt resource
Create a new prompt
The below attributes are optional:

callback is a URL that will be called when the prompt is done processing. The callback is a POST request where the body contains the prompt object.

ar Aspect-Ratio. 1:1, portrait, 16:9, landscape, anamorphic

num_images Number of images to generate. Values: 4, 8

face_correct - Boolean. Runs another AI model on top to correct the face in the image.

ControlNet parameters:

controlnet - BETA. Requires input_image. Possible values: canny, depth, mlsd, hed.

denoising_strength - BETA. Requires input_image. Possible values: canny, depth, mlsd, hed.

input_image - BETA. Binary multi-part request with the image. Used in conjunction with controlnet parameter.

input_image_url - BETA. URL to an image. Used in conjunction with controlnet parameter.

Note that you can control `cfg_scale`, `seed`, `steps` as well, however Astria provides some good defaults for these.

curl -X POST -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes/26/prompts \
          -F prompt[text]="a painting of sks man in the style of alphonse mucha" \
          -F prompt[negative_prompt]="extra leg" \
          -F prompt[super_resolution]=true \
          -F prompt[face_correct]=true \
          -F prompt[callback]="https://optional-callback-url.com/to-your-service-when-ready"
{
  "id": 29,
  "callback": "https://optional-callback-url.com/to-your-service-when-ready",
  "text": "a painting of sks man in the style of alphonse mucha",
  "negative_prompt": "3 legs, 4 legs",
  "cfg_scale": null,
  "steps": null,
  "seed": null,
  "trained_at": null,
  "started_training_at": null,
  "created_at": "2022-10-06T16:12:54.505Z",
  "updated_at": "2022-10-06T16:12:54.505Z",
  "tune_id": 26,
  "url": "http://api.astria.ai/tunes/26/prompts/29.json"
}
Get all prompts of a fine-tune
Use the offset parameter to paginate through the results.

curl -X GET -H "Authorization: Bearer $API_KEY" https://api.astria.ai/tunes/1/prompts?offset=0
[...array of prompts...]
```
