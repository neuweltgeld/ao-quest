# AOS-DEVCHAT

This project is a Discord bot that interacts with a backend API and uses worker threads to handle background tasks. The bot is configured using environment variables and includes several modules for different functionalities.

## Project Structure

```
.
├── fetch
│ ├── message.js
│ ├── bot.js
├── tools
│ ├── http.js
├── config.js
├── index.js
├── .env
```

### Files and Directories

- **fetch/message.js**: Contains the function to send messages to Discord.
- **fetch/bot.js**: Contains the bot that handles background tasks and polls for messages.
- **tools/http.js**: Axios instance configuration for making HTTP requests to the backend API.
- **config.js**: Configuration file that loads settings from environment variables.
- **index.js**: Main entry point for the Discord bot, handles incoming messages and routes them to the appropriate handlers.
- **.env**: Environment variables file, used for configuration settings.

## Getting Started

### Prerequisites

- Node.js
- aos
- npm (Node Package Manager)
- ws, express, fs, discord.js, @permaweb/aoconnect packages

### .env 

```console
NODE_ENV=production
backendApi=your_backend_api_url
channelId=your_channel_id
processId=your_process_id
DISCORD_TOKEN=your_discord_token
```
```console
# npm start
npm run start

# aos message commands

Send({ Target = ao.id, Action = "Register" })

Send({Target = ao.id, Action = "Broadcast", Data = "Aos chat message from AOS" })

```


![Ekran görüntüsü 2024-05-30 224055](https://github.com/neuweltgeld/ao-quest/assets/101174090/9491fd49-d1ac-4de6-b654-bc28a0cf86ba)

![Ekran görüntüsü 2024-05-30 224102](https://github.com/neuweltgeld/ao-quest/assets/101174090/b199ddeb-c8e8-4b80-ae69-817305099193)
