import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '20s',
  thresholds: {
    http_req_duration: ['p(95)<800'],
  },
};

const BASE_URL = __ENV.API_URL || 'https://eventmanagementproject-production-94fe.up.railway.app/api';

export default function () {
  const payload = JSON.stringify({
    email: 'manager@eventcraft.lk',
    password: 'Manager@2026',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(`${BASE_URL}/auth/login`, payload, params);

  check(res, {
    'status is 200': (r) => r.status === 200,
    'token is present': (r) => r.body.includes('token'),
  });

  sleep(1);
}
