import axios from 'axios';

// ASP.NET Core Backend API URL (ඔබේ Backend එක run වන port එක)
const API_BASE_URL = 'http://localhost:5000/api'; 

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export interface EventItem {
  eventId: string;
  title: string;
  targetDate: string;
  guestCount: number;
  budgetLimit: number;
  status: string;
  venueName?: string;
  createdAt: string;
}

export const eventService = {
  getMyEvents: async (): Promise<EventItem[]> => {
    const response = await apiClient.get<EventItem[]>('/events/my-events');
    return response.data;
  },
  createEvent: async (eventData: Partial<EventItem>) => {
    const response = await apiClient.post('/events', eventData);
    return response.data;
  },
};