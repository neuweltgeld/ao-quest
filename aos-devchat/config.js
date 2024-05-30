require('dotenv').config();

const config = {
	production: {
		backendApi: process.env.backendApi,
		channelId: process.env.channelId,
		processId: process.env.processId,
	},
	development: {
		backendApi: 'http://localhost:3000',
		channelId: 'local_channel_id',
		processId: 'local_process_id',
	},
};

const environment = process.env.NODE_ENV || 'development';
console.log(`Running in ${environment} mode`);
const settings = config[environment];

module.exports = settings;
