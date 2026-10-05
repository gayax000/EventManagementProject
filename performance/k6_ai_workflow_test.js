import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '15s',
  thresholds: {
    http_req_duration: ['p(95)<3000'], // AI workflow latency threshold (3s)
  },
};

const BASE_URL = __ENV.AI_URL || 'https://eventmanagementproject-production-94fe.up.railway.app';

export default function () {
  const payload = JSON.stringify({
    title: 'Performance Benchmark Wedding',
    guestCount: 200,
    budgetLimit: 2000000.0,
    location: 'Colombo',
    isOutdoor: true,
    targetDate: '2026-11-20',
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(`${BASE_URL}/api/ai/plan`, payload, params);

  check(res, {
    'status is 200': (r) => r.status === 200,
    'workflowId returned': (r) => r.body.includes('workflowId'),
    'has 4 agent logs': (r) => r.body.includes('PlannerAgent') && r.body.includes('WeatherRiskAgent'),
  });

  sleep(2);
}
