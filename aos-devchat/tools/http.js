const axios = require('axios');
const settings = require('./config');

const request = axios.create({
	baseURL: settings.backendApi,
	timeout: 5000,
});

request.interceptors.request.use(
	config => config,
	error => Promise.reject(error)
);

request.interceptors.response.use(
	response => {
		const responseData = response.data;
		if (responseData && responseData.code === 200) {
			return responseData;
		}
		console.error('Server returned an error', response.data);
		return Promise.reject(response.data);
	},
	error => Promise.reject(error)
);

module.exports = request;
