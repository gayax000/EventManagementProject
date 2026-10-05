import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 20 }, // Ramp-up to 20 users
    { duration: '30s', target: 50 }, // Stay at 50 users
    { duration: '10s', target: 0 },  // Ramp-down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.01'],    // HTTP error rate must be less than 1%
  },
};

const BASE_URL = __ENV.API_URL || 'https://eventmanagementproject-production-94fe.up.railway.app/api';

export default function () {
  const res = http.get(`${BASE_URL}/venues?pageNumber=1&pageSize=10`);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'has paginated items': (r) => r.body.includes('items'),
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
