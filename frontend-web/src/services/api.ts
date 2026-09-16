import axios from 'axios';

// ASP.NET Core Backend Base URL
const API_BASE_URL = 'http://localhost:5147/api'; 

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
  venueId?: string;
  venueName?: string;
  createdAt: string;
}

export const eventService = {
  // Fetch events list
  getMyEvents: async (): Promise<EventItem[]> => {
    const response = await apiClient.get<EventItem[]>('/events/my-events');
    return response.data;
  },

  // Manager Approve Proposal
  approveProposal: async (eventId: string, discount: number = 0) => {
    const response = await apiClient.post(`/events/${eventId}/approve-proposal?discount=${discount}`);
    return response.data;
  },

  // Create Event Request
  createEvent: async (eventData: Partial<EventItem>) => {
    const response = await apiClient.post('/events', eventData);
    return response.data;
  },
};