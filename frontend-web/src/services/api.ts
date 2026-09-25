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
  eventType?: string;
  targetDate: string;
  guestCount: number;
  budgetLimit: number;
  status: string;
  venueId?: string;
  venueName?: string;
  banquetHallId?: string;
  banquetHallName?: string;
  hallRentalPrice?: number;
  perPlatePrice?: number;
  isOutdoor?: boolean;
  additionalDetails?: string;
  selectedServices?: string[];
  eventSession?: string;
  cateringStyle?: string;
  tableRefreshments?: string[];
  revisionNotes?: string;
  inspirationImages?: string[];
  inspirationImageUrl?: string;
  weatherAssessment?: any;
  estimatedTotalCost?: number;
  createdAt: string;
}

export interface BanquetHallItem {
  banquetHallId: string;
  venueId: string;
  venueName: string;
  hallName: string;
  maxCapacity: number;
  hallRentalPrice: number;
  perPlatePrice: number;
  isOutdoor: boolean;
  isAvailable: boolean;
}

export const banquetHallService = {
  getHalls: async (venueId?: string, date?: string): Promise<BanquetHallItem[]> => {
    let url = '/banquethalls';
    const params = new URLSearchParams();
    if (venueId) params.append('venueId', venueId);
    if (date) params.append('date', date);
    if (params.toString()) url += `?${params.toString()}`;
    const response = await apiClient.get<BanquetHallItem[]>(url);
    return response.data;
  },
};

export const eventService = {
  // Fetch events list
  getMyEvents: async (): Promise<EventItem[]> => {
    const response = await apiClient.get<EventItem[]>('/events/my-events');
    return response.data;
  },

  // Manager Approve Proposal with exact finalTotal and optional status & customAddonCost
  approveProposal: async (eventId: string, discount: number = 0, finalTotal?: number, status?: string, customAddonCost?: number, planItems?: string[]) => {
    let url = `/events/${eventId}/approve-proposal?discount=${discount}`;
    if (finalTotal !== undefined) {
      url += `&finalTotal=${finalTotal}`;
    }
    if (status !== undefined) {
      url += `&status=${encodeURIComponent(status)}`;
    }
    if (customAddonCost !== undefined) {
      url += `&customAddonCost=${customAddonCost}`;
    }
    const response = await apiClient.post(url, planItems || null);
    return response.data;
  },

  // Get specific event proposal
  getProposal: async (eventId: string) => {
    const response = await apiClient.get(`/events/${eventId}/proposal`);
    return response.data;
  },

  // Create Event Request
  createEvent: async (eventData: Partial<EventItem>) => {
    const response = await apiClient.post('/events', eventData);
    return response.data;
  },

  // Delete Event Request
  deleteEvent: async (eventId: string) => {
    const response = await apiClient.delete(`/events/${eventId}`);
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
  packageName?: string;
  packagePrice?: number;
}

export const vendorService = {
  getVendors: async (): Promise<VendorItem[]> => {
    const res = await apiClient.get('/venues/vendors');
    return res.data;
  },
  registerVendor: async (data: { businessName: string; category: string; contactNumber: string; description?: string; packageName?: string; packagePrice?: number }) => {
    const res = await apiClient.post('/venues/vendors/register', data);
    return res.data;
  },
  verifyVendor: async (id: string, status: 'Verified' | 'Rejected', adminRemarks?: string) => {
    const res = await apiClient.put(`/venues/vendors/${id}/verify`, { status, adminRemarks });
    return res.data;
  },
  deleteVendor: async (id: string) => {
    const res = await apiClient.delete(`/venues/vendors/${id}`);
    return res.data;
  },
};

export interface LivePaymentItem {
  id: string;
  bookingRef: string;
  clientName: string;
  eventTitle: string;
  amount: number;
  slipUrl: string;
  date: string;
  status: string;
  rejectReason?: string;
  invoiceNumber?: string;
}

export const paymentService = {
  getPayments: async (): Promise<LivePaymentItem[]> => {
    const res = await apiClient.get('/payments');
    return res.data;
  },
  verifyPayment: async (id: string, status: 'Approved' | 'Rejected', rejectReason?: string) => {
    const res = await apiClient.put(`/payments/${id}/verify`, { status, rejectReason });
    return res.data;
  },
  getRevenueForecast: async () => {
    const res = await apiClient.get('/payments/analytics/revenue-forecast');
    return res.data;
  },
};