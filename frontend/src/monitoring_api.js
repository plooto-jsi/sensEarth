import axios from 'axios';

const monitoring_api = axios.create({
  baseURL: "http://localhost:8001"});

export default monitoring_api;