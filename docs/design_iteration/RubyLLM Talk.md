- url::
- ---
- [[Carmen Palino]]. You can call me Carmine. It's okay. I'm the creator of [[Chatwood]], where [[Ruby LLM]] was extracted from. I was also a co-founder of another company in AI as well. and I've been a [[Ruby]] enthusiast since 2010.
- When I saw Ruby the first time, I fell in love with it. But then I went to study AI, became a [[data scientist]], [[machine learning engineer]], and scientist. And so I've been in the [[Python]] AI world for a long time.
- And [[Python]] owns AI and it owns AI for a reason because AI was about [[training models]]. And we had [[numpy]], we had [[scipy]], we had [[scikit-learn]], [[tensorflow]], you name it. But now AI is this. It's [[API calls]]. And it's great because that means that we can actually focus on other things. [[AI development]] today is more about building great products. And who is good at building great products than [[Rubyists]]?
- So I want to show you that [[Ruby LLM]] with [[Rails]] is the one API, one person, one machine framework for AI.
- Let's first dismantle some myths or some mind viruses. Oh, there you go. How many of you has heard this or some kind of version of this? Few. All right. You need a complex [[agent framework]] or you're not doing real AI. Well, let's that's I'm going to show you why.
- Comparing simple templates for agents, using python and RubyLLM 
    - Let's look at a simple chat with [[Python]] [[LangChain]]. This is actually from their first tutorial. So, don't mind me if there's this weird get pass in there. So, here we're importing some stuff. Then we're getting the [[OpenAI API]] key, initiating the [[chat model]], and then creating this messages with human message object content hello, then model.invoke messages.
    - Does it have to be this way? I don't think so. I think AI can be simple and it should be natural.
    - Let's look at another example. This is [[prompt templates]]. You know, I've been asked many times in the repo, when are you going to have prompt templates? And I always say no. And this is why. Here's prompt templates in [[LangChain]]. You need to import the [[chat prompt template]] class, then initialize it from messages. There's a bunch of like arrays and tuples and whatever. And then you need to format these messages. And that you need to initialize the chat model and blah blah blah and invoke it. This is how to do it in [[Ruby LLM]]. Turns out we have Ruby that has templates for text. Crazy, right? It's just two lines of code.
        - So please don't drink the [[complexity tonic]] by Dr. [[LangChain]]. Okay. It has 10,000 classes. So that's when you know it's serious.
- Token Tracing with Big AI sdk and boilerplate methods:: 
    - Here's another example. So they claim to be the, you know, the one framework that you can use with all the different models out there and it has one interface. Well, that's too. Look at this. In order to find the usage, actually, can you guys spot where the usage the the amount of tokens that we used in this conversations are? Yeah, they're there. Right? This is with [[GPT-4]]. Let's look at with [[Claude 3.7]] completely different response. Now they're here. So your code will be a bunch of if statements or a bunch of other classes that need to parse this anyway. And let's look at with [[Gemini]] is nowhere to be found. What I think there's a better way.
    - This is how we do it in [[Ruby LLM]]. You have the chat.ask task method and then [[input and output tokens]] you want to change to 3.7 it's always there same thing with Gemini it's actually there.
- Multi-modality:: 
    - What about [[multimodality]]? Here is how to do it in [[LangChain]] which by the way I had to search for a blog post in order to find this anyway. Here we're just importing some models some code and then we're fetching the URL the image URL and then we're encoding it in [[base64]] then we're initializing the chat model then we have to create this whole structure with a dictionary it's a hash in Python lingo with role user content and then an array and then type text text describe this weather in this image then you have to know how to do this and then you can finally invoke it to your [[LLM]]. This is how to do this on [[Ruby LLM]] require rubyllm image URL is this and then you just pass it on the width parameter of the ask method that's it.
    - I think what we need is clean [[abstractions]] at the right level not this [[complexity theater]] and this is the reason why we have that complexity theater is the [[merchants of complexity]]. [[David]] has told us this many many times and it's True. Look at their page. It sells an [[enterprise support package]]. Their documentation is pretty bad and they want you to pay for you to actually make your code good.
- [[[[CLM]] - SDK'S from the different major AI frameworks prescribe their own distinct, opinionated schema and data model, representing core primatives like tool calling and context engineering workflows, slightly different then each other. This forces a Constrained Mental from the start, which limits the creative vision. ]]
- Another myth, you need to use the [[official SDKs]]. This is more of a corporate thing. Usually you hear it in corporates saying like you need to use the official SDK because this is the most supported blah blah blah. Well, in AI it's Christmas every day. We get many many models all the time. You know, I switched from [[Gemini 2.0]] to [[Claude 3.7]], then [[GPT-4.1]], and then [[Gemini 2.5]], then [[Claude 4]], etc., etc. And every time, if every time I had to switch, I don't know what's happening with every time I had to switch, I had to reimplement the API with the provider APIs, I would have been dead. If you can't switch fast, you're dead.
- So I built [[Ruby LLM]] and I built this on five principles and this is the philosophy. Simple should be simple and complex should be possible. [[Models and providers are commodities]]. [[Convention over configuration]] of course and [[progressive disclosure]]. And finally one API, one person, one machine.
- Linux is great, guys. Like, use it. This is not Linux. I love Linux, by the way.
- Oh, very nice. Simple should be simple. This we've seen it already, but we haven't seen with the official provider SDKs. This is still Python, but you you know the gist. And this is the official [[OpenAI]] Python library. Still quite a bit of code for a simple hello.
- We can go one step further in this if you know if you're using the default model. Complex should be possible though. This is 20 lines of code and believe it or not there are four agents working in this 20 lines of code. So we have a [[code review]] [[multi-agent system]]. The first agent is a [[security reviewer]] using [[Claude Sonnet 4]]. Second agent is doing [[performance review]] with [[GPT-4.1]]. Third agent is doing [[style review]] with [[GPT-4.1 mini]]. They're all doing it at the same time concurrently with [[async]]. And then there is a fourth agent that is summarizing these code reviews. 20 lines of code, four agents. You don't need complexity.
- [[Models are commodities]]. We've seen this before. If you say do you want to have [[Claude Sonnet 4]], it's going to use the [[Anthropic API]] in the back end automatically because we know which models are from which providers. And if you switch it to [[Gemini 2.5 flash]], it's going to switch also which API is going to use and they're completely different APIs. Well, don't worry. We're going to handle that for you.
- Also, you may want to switch the provider but having the same model. Let's say you want to use [[Vertex AI]] version of Gemini 2.5 Flash. This is how to do it. That's it. [[OpenRouter]] is an [[OpenAI compatible]] provider and again another type of API same model.
- This is to how to use [[local models]] with [[Ollama]]. Very very simple. And not only that, we support 11 providers right now. We're planning to support more. We support any [[OpenAI compatible]] one. So, probably there are way way more than than just 11. We have 620 models in our [[model registry]] all under one single API.
- Not only that, [[Ollama]] and [[GPU Stack]] are [[local model providers]] and GPU Stack supports all of the [[Hugging Face]] models and all of the [[Model Scope]] models which are thousands of models. And our [[model registry]] has [[cost and capabilities tracking]] so you know actually how much you're spending. I used to spend a lot of time trying to find this information and documentation of the providers and we have it all in [[Ruby LLM]] in the model registry.
- Thank you. Also thanks to [[Parera]] who's doing the grunt work of actually parsing the documentation and providing us with an API that we can actually use in Ruby LLM for this.
- There's one more thing. So let's say you're chatting with an AI and you don't like their responses so much. You want to change mid-conversation. You can with [[chat.with model]]. Basically, you're going to have four messages, one from you, one from [[GPT-5]], one from you, and one from [[Gemini 2.5 Flash]] in the same conversation.
- [[Convention over configuration]]. We know about this, right? We've seen this before already. [[Ruby LLM.chat.ask]] already knows what is your default model. It's going to use that. But also the [[paint method]] is going to use the default model. the [[embed method]], so you can do [[embeddings]] as well, and the [[moderate method]], so you can moderate your content. All very easy, the least amount of keywords possible.
- Here's the other concept, [[progressive disclosure]]. So, we start with that. And let's say we want to add some [[system prompt]]. I don't think system prompt is a nice name, so I call it [[instructions]]. So, it's chat with instructions. Let's say you want to add an image of a Ruko logo. Here's how to do it. Let's say you want to add two images. You know, you can actually add audio, you can add PDFs, you can add text, and you can also add videos from one of the latest releases, the last release.
- You want to change the [[temperature]], pretty simple. you want to add parameters to our payload, you can do that very simply. So if you have a feature that you want to use in your LLM that we don't support, you can simply add it that way like [[JSON mode]] for example and you can add others as well.
- What if you want to do [[function calling]]? So you simply do this. you subclass from [[tool]] and then you add a description for your tool. It's very important to do a good description here because your LLM needs to understand what your tool is for. You add the parameters and you add an [[execute function]] with those parameters and this is actually working code. It's cut obviously but you can go on the website and copy paste it and actually this works and retrieves you the weather of Vienna and that's it. You just add dot with tool.
- We also have [[structured output]] support and thanks to the [[Ruby LLM Schema]] gem which is a companion gem made by [[Daniel Freeze]]. We have this beautiful [[DSL]] I believe is the best DSL in Ruby for creating [[JSON schemas]]. And it's very very simple. Let's say you want to have a product schema with a name, a price, and an array of features. As simple as that. Dot with schema.
- We also have a [[Rails integration]]. In fact, you can go from zero to a [[chat UI]] in less than two minutes. Let me show you. Okay, so we're making a new Rails app. Needs to install everything. This is real time. We're going there. Adding Ruby LLM. And now we're going to use the [[install generator]] in order to create all the migrations and all the models that we need. And we do rails db migrate. And it's actually also loading the models from a [[model registry]] into your DB. So then you can query them.
- Here's where I get a message from [[Greg Molnar]] because of the API key. Don't worry. And this is how to chat. So we just do [[chat.create]] is the same as rubyllm.chat, but it's an [[active record]] and we're saying hello to [[GPT-4.1 nano]] in a few seconds. Now we can continue the conversation. There we go. Hello to the folks at We're respecting the last chat. And here are the messages all stored in [[active record]] for you. You have to do absolutely nothing.
- Let's see the model. And as you can see, we have all the [[modalities]], all the capabilities, and all the pricing for that model that has been used for that chat. And we have also all the models that you can query. So you can see which one is the cheapest, which one has the different capabilities that you need.
- Okay, how about we make it actually a UI? We have a generator. It's [[chat UI generator]] and let's actually run it. Switch to our browser. We go to /chats and we already have the chats from before. Here's how they look like. It's not meant to be beautiful. was just like a Rails generator and we're continuing the conversation and it's all with [[Hotwire]] and [[Turbo]].
- Let's make a new chat. What's the best programming language? Please say Ruby. And here we go. We also have tokens that stream inside the browser already. here. I just want to argue a little bit because didn't say that Ruby is the best. yeah, didn't tell me that absolutely right this time. I think it's a different model. So this is the models interface. Very, very simple, but it shows you how much they cost. And there's a refresh models button that refreshes all the models when they come up.
- And here's the code. So this is the [[model model]]. You just add [[acts_as_model]] and you have all the facilities you need in order to store the models. This is the [[message model]]. I removed that empty line. It's a [[broadcast to message]] and then there's an [[acts_as_message]] and just some attachments. And this is the chat. It has [[acts_as_chat]] which adds all the methods that we need in order to have that. And then [[tool call]] also [[acts_as_tool_call]] adds all the methods we need.
- Let's look at the controllers of that. So, as you can see, the refresh as [[model.refresh]]. Simple as that. We handle all of that for you. Anytime now. There you go. We have also the chat controller. Very, very simple. It's just these lines of code. and we go up and we just create a new chat. And then we invoke a [[chat response job]] with the prompt and the chat ID. Simple as that.
- Let's look at the [[chat response job]]. So we find the chat and then we use chat.ask. And here we have a [[streaming block]] in which we get every single chunk that comes in and we simply update it inside the content of the message. Don't do this in production. This is not great. But this is just for simplicity and showing you how simple it can be to make it work.
- Let's look at the messages controller. Pretty simple again. Just a chat response job. And that's it. We have a full [[chat UI]] in less than five minutes with all this mocking around that we did.
- But does it scale? Turns out [[LLM communication]] is just [[IO bound]] and it's long running. So you need to be a little bit careful about this in terms of what job background job workers you use. So if you use a [[worker based job queue]] well if you have 100 chats you will consume 100 workers which mean and also you will have a [[DB connection pool]] that needs to add 100 connections to the DB connections pool. Now your 101 client is gonna wait like he wrote his own prompt and it's going to wait in there and each worker unfortunately is not doing much is not doing almost anything. It's just waiting for the next token.
- Instead if you use [[async job]] which is [[fiber-based]] doesn't have a max workers. Well, 100 chats means 100 [[fibers]]. You don't need a bigger connection DB connection pool and it uses your resources efficiently because you can do it all concurrently. This is a big topic guys. I cannot go into this in this presentation but I have a link to my blog. There's a little bit more explanation there or find me in the hallway there.
- And that's all you need in order to scale. Simply replace [[Puma]] with [[Falcon]]. Replace whatever job Q adapter you have with [[async job]] and then replace whatever cable adapter you have with [[async cable]]. You need this because a PR wasn't merged and then this initializer. That's it. No code changes needed and you can scale.
- So that's it. This is [[Ruby LLM]] which is the one API for one person and one machine for thousands of users. But don't take my word for it. So when I started coding Ruby LLM in like February this year, I did it for myself. I did it for [[Chatwood]] and then I extracted into a gem. I released it the 11th of March and I expected maybe 300 stars. Four days later was the number one story on [[Hacker News]].
- This is actually funny. It's the fourth biggest story on Hacker News about Ruby. And this is the star history. We got to 1,700 stars in one week and 2,900 stars today and 3 million downloads. So, it means that people want this.
- Again, more bragging. And this is what developers are saying. I love these quotes, actually. So, [[Ruby LLM]] is a better tool than any other Python library I used before. Yes, exactly. You got it. Ruby LLM is such a cool gem. I started using it today and got it running in less than 3 minutes. And these are from my survey. Ruby LLM is pretty much the [[Devise]] of this generation. And we got our proof of concept up in one day. Got the first version into beta testing in about a week. Love it. And it's used that these companies and many more. These are just the companies that have responded to my survey and I've actually agreed to put their logos in there. And there's some big ones like [[Zip Chat]], [[Startup Jobs]], [[Kora]]. And this is amazing. I can just from these companies I could tell that more than half a million people are actually using Ruby LLM as users of these products.
- Guys, this is our time. [[Python]] and [[JavaScript]] have dominated the AI app world. But we have [[Rails]]. We have [[Ruby LLM]]. We have the tools that can make you go from hello to [[ChatGPT]] to IPO with one person and one machine and one API.
- And you know when we freed ourselves from complexity back in when Rails came up this community built [[Twitter]], [[GitHub]], [[Basecamp]], [[Shopify]]. Rails changed the world, the web app world. Now we have the chance to change the AI app world. Thank you.
- ---
- **Final word count:** 2,876 words (content preserved, timestamps removed)
- **Key concepts tagged:** [[Ruby LLM]], [[Rails]], [[Carmen Palino]], [[Chatwood]], [[LangChain]], [[Python]], [[convention over configuration]], [[progressive disclosure]], [[complexity theater]], [[model registry]], [[OpenAI]], [[Anthropic]], [[Gemini]], [[Claude]], [[GPT-4]], [[Ollama]], [[function calling]], [[structured output]], [[JSON schemas]], [[Hotwire]], [[Turbo]], [[Falcon]], [[async job]], [[fibers]], [[Puma]], [[Hacker News]]
- ---
- # Ruby LLM: Instructions & Key Takeaways
- ## Philosophy: Five Core Principles
    - 1. **Simple should be simple, complex should be possible** - Basic tasks should require minimal code; advanced features remain accessible
    - 2. **Models and providers are commodities** - Switch between any model/provider without code changes
    - 3. **Convention over configuration** - Sensible defaults eliminate boilerplate
    - 4. **Progressive disclosure** - Start simple, add complexity only as needed
    - 5. **One API, one person, one machine** - Solo developers can build production AI apps
    - ---
- ## Quick Start
- ### Installation
    - ```ruby
      # Add to Gemfile
      gem 'ruby_llm'
      
      # Run install generator (creates migrations + models)
      rails generate ruby_llm:install
      rails db:migrate
      ```
- ### Basic Chat
    - ```ruby
      # Simplest possible - uses default model
      RubyLLM.chat.ask("Hello")
      
      # Specify a model
      RubyLLM.chat.ask("Hello", model: "gpt-4.1")
      ```
    - ---
- ## Key Features
- ### Model Switching (Zero Code Changes)
    - ```ruby
      # Automatically uses correct API for each provider
      chat.ask("Hello", model: "claude-sonnet-4")  # Uses Anthropic API
      chat.ask("Hello", model: "gemini-2.5-flash") # Uses Google API
      chat.ask("Hello", model: "gpt-4.1")          # Uses OpenAI API
      
      # Switch providers for same model
      chat.ask("Hello", model: "gemini-2.5-flash", provider: :vertex_ai)
      chat.ask("Hello", model: "gemini-2.5-flash", provider: :openrouter)
      
      # Local models
      chat.ask("Hello", model: "llama3", provider: :ollama)
      ```
- ### Mid-Conversation Model Switching
    - ```ruby
      chat.with_model("gpt-5").ask("First question")
      chat.with_model("gemini-2.5-flash").ask("Follow up")
      # Same conversation, different models
      ```
- ### Multimodality
    - ```ruby
      # Images, audio, PDFs, video - just pass them
      chat.ask("Describe this", with: image_url)
      chat.ask("Analyze", with: [image1, image2, pdf_file])
      ```
- ### Function Calling / Tools
    - ```ruby
      class WeatherTool < RubyLLM::Tool
        description "Get weather for a location"
        parameter :city, type: :string, required: true
        
        def execute(city:)
          # Your implementation
        end
      end
      
      chat.with_tool(WeatherTool).ask("What's the weather in Vienna?")
      ```
- ### Structured Output
    - ```ruby
      # Using ruby_llm_schema gem
      schema = RubyLLM::Schema.define do
        string :name
        number :price
        array :features, items: { type: :string }
      end
      
      chat.with_schema(schema).ask("Extract product info")
      ```
- ### Multi-Agent System (20 Lines)
    - ```ruby
      # Four agents working concurrently
      security = chat.model("claude-sonnet-4").ask_async(code, instructions: "Security review")
      performance = chat.model("gpt-4.1").ask_async(code, instructions: "Performance review")  
      style = chat.model("gpt-4.1-mini").ask_async(code, instructions: "Style review")
      
      reviews = [security, performance, style].map(&:value)
      summary = chat.ask("Summarize these reviews: #{reviews}")
      ```
    - ---
- ## Rails Integration
- ### ActiveRecord Concerns
    - ```ruby
      class Model < ApplicationRecord
        acts_as_model  # Model registry integration
      end
      
      class Chat < ApplicationRecord
        acts_as_chat   # Chat methods
      end
      
      class Message < ApplicationRecord
        acts_as_message  # Message handling + broadcasts
      end
      
      class ToolCall < ApplicationRecord
        acts_as_tool_call
      end
      ```
- ### Chat UI Generator
    - ```plain text
      rails generate ruby_llm:chat_ui
      # Creates full streaming chat interface with Hotwire/Turbo
      ```
- ### Streaming in Background Jobs
    - ```ruby
      class ChatResponseJob < ApplicationJob
        def perform(prompt, chat_id)
          chat = Chat.find(chat_id)
          chat.ask(prompt) do |chunk|
            # Stream each token to browser
            message.update(content: message.content + chunk)
          end
        end
      end
      ```
    - ---
- ## Scaling for Production
    - **Problem:** LLM calls are IO-bound and long-running. Worker-based job queues block on each request.
    - **Solution:** Use fiber-based concurrency
    - ```ruby
      # config/puma.rb → config/falcon.rb
      # Replace Puma with Falcon
      
      # config/application.rb
      config.active_job.queue_adapter = :async
      
      # config/cable.yml  
      adapter: async
      ```
    - **Result:** 100 concurrent chats = 100 fibers (not 100 workers), no DB connection pool bloat
    - ---
- ## Model Registry
    - **620+ models** across 11 providers under one API
    - **Cost tracking** - know what you're spending
    - **Capability tracking** - query by features needed
    - **Auto-refresh** - stays current with new models
    - ```ruby
      Model.where(supports_vision: true).order(:input_cost_per_token)
      ```
    - ---
- ## Why Not LangChain?
    - {{[[table]]}}
        - Task
            - LangChain
                - Ruby LLM
        - Simple chat
            - ~10 lines + imports
                - 1 line
        - Prompt templates
            - Custom class + format
                - Ruby string interpolation
        - Token usage
            - Different location per provider
                - Always `chat.input_tokens`, `chat.output_tokens`
        - Multimodality
            - Blog post hunting + base64 encoding
                - `ask("Describe", with: image_url)`
        - Classes
            - 10,000+
                - Minimal
    - **Key insight:** LangChain is "complexity theater" - it sells enterprise support by making things complicated. Ruby LLM provides clean abstractions at the right level.
    - ---
- ## Core Argument
    - > "Python owned AI because AI was about training models. But now AI is API calls. AI development today is more about building great products. And who is good at building great products? Rubyists."
