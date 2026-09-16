import axios from 'axios';

// ASP.NET Core Backend Base URL (Railway Production Cloud)
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://eventmanagementproject-production.up.railway.app/api'; 

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('jwt_token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

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

export const venueService = {
  getVenues: async (search?: string) => {
    const url = search ? `/venues?search=${encodeURIComponent(search)}` : '/venues';
    const response = await apiClient.get(url);
    return response.data;
  },
};

export interface VendorItem {
  id?: string;
  vendorId?: string;
  name?: string;
  businessName?: string;
  category: string;
  contact?: string;
  contactNumber?: string;
  status?: string;
  verificationStatus?: string;
  adminRemarks?: string;
}

export const vendorService = {
  getVendors: async (): Promise<VendorItem[]> => {
    const res = await apiClient.get('/venues/vendors');
    return res.data;
  },
  registerVendor: async (data: { businessName: string; category: string; contactNumber: string; description?: string }) => {
    const res = await apiClient.post('/venues/vendors/register', data);
    return res.data;
  },
  verifyVendor: async (id: string, status: 'Verified' | 'Rejected', adminRemarks?: string) => {
    const res = await apiClient.put(`/venues/vendors/${id}/verify`, { status, adminRemarks });
    return res.data;
  },
};